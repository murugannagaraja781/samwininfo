<?php
// ==========================================================
// Tenkasi Dreams Land - Real-Time In-App Chat API (chat.php)
// Connects Property Poster (Seller) & Property Viewer (Buyer)
// ==========================================================

require_once __DIR__ . '/config.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$chatsFile = DATA_DIR . '/chats.json';

function getJsonChats($file) {
    if (!file_exists($file)) {
        return ['conversations' => [], 'messages' => []];
    }
    $raw = file_get_contents($file);
    $data = json_decode($raw, true);
    if (!is_array($data)) {
        return ['conversations' => [], 'messages' => []];
    }
    if (!isset($data['conversations'])) $data['conversations'] = [];
    if (!isset($data['messages'])) $data['messages'] = [];
    return $data;
}

function saveJsonChats($file, $data) {
    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

function cleanPhone($phone) {
    return preg_replace('/[^0-9]/', '', (string)$phone);
}

// Auto-create chat tables in MySQL if connected
$pdo = getDbConnection();
if ($pdo) {
    try {
        $pdo->exec("CREATE TABLE IF NOT EXISTS `chat_conversations` (
            `id` VARCHAR(64) PRIMARY KEY,
            `property_id` VARCHAR(64) NOT NULL,
            `property_title` VARCHAR(255) DEFAULT '',
            `buyer_name` VARCHAR(150) DEFAULT '',
            `buyer_phone` VARCHAR(50) NOT NULL,
            `seller_name` VARCHAR(150) DEFAULT '',
            `seller_phone` VARCHAR(50) NOT NULL,
            `last_message` TEXT,
            `last_message_time` DATETIME NOT NULL,
            `created_at` DATETIME NOT NULL,
            INDEX (`property_id`),
            INDEX (`buyer_phone`),
            INDEX (`seller_phone`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        $pdo->exec("CREATE TABLE IF NOT EXISTS `chat_messages` (
            `id` VARCHAR(64) PRIMARY KEY,
            `conversation_id` VARCHAR(64) NOT NULL,
            `property_id` VARCHAR(64) NOT NULL,
            `sender_phone` VARCHAR(50) NOT NULL,
            `sender_name` VARCHAR(150) DEFAULT '',
            `sender_role` VARCHAR(20) DEFAULT 'buyer',
            `message` TEXT NOT NULL,
            `is_read` TINYINT(1) DEFAULT 0,
            `created_at` DATETIME NOT NULL,
            INDEX (`conversation_id`),
            INDEX (`sender_phone`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");
    } catch (Exception $e) {}
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

switch ($method) {
    case 'GET':
        $action = $_GET['action'] ?? 'messages';

        // 1. Get messages for a conversation or property+buyer
        if ($action === 'messages') {
            $convId = trim($_GET['conversation_id'] ?? '');
            $propId = trim($_GET['property_id'] ?? '');
            $buyerPhone = cleanPhone($_GET['buyer_phone'] ?? '');

            $messages = [];

            if ($pdo) {
                try {
                    if (!empty($convId)) {
                        $stmt = $pdo->prepare("SELECT * FROM `chat_messages` WHERE `conversation_id` = ? ORDER BY `created_at` ASC LIMIT 500");
                        $stmt->execute([$convId]);
                        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    } elseif (!empty($propId) && !empty($buyerPhone)) {
                        // Find conversation
                        $cStmt = $pdo->prepare("SELECT `id` FROM `chat_conversations` WHERE `property_id` = ? AND (REPLACE(REPLACE(REPLACE(buyer_phone, ' ', ''), '+', ''), '-', '') LIKE ?) LIMIT 1");
                        $cStmt->execute([$propId, '%' . $buyerPhone . '%']);
                        $conv = $cStmt->fetch(PDO::FETCH_ASSOC);
                        if ($conv) {
                            $convId = $conv['id'];
                            $mStmt = $pdo->prepare("SELECT * FROM `chat_messages` WHERE `conversation_id` = ? ORDER BY `created_at` ASC LIMIT 500");
                            $mStmt->execute([$convId]);
                            $messages = $mStmt->fetchAll(PDO::FETCH_ASSOC);
                        }
                    }
                } catch (Exception $e) {}
            }

            // Fallback to JSON
            if (empty($messages)) {
                $data = getJsonChats($chatsFile);
                $allMsgs = $data['messages'];
                if (!empty($convId)) {
                    $messages = array_values(array_filter($allMsgs, function($m) use ($convId) {
                        return ($m['conversation_id'] ?? '') === $convId;
                    }));
                } elseif (!empty($propId) && !empty($buyerPhone)) {
                    $convs = $data['conversations'];
                    foreach ($convs as $c) {
                        if (($c['property_id'] ?? '') === $propId && cleanPhone($c['buyer_phone'] ?? '') === $buyerPhone) {
                            $convId = $c['id'];
                            break;
                        }
                    }
                    if (!empty($convId)) {
                        $messages = array_values(array_filter($allMsgs, function($m) use ($convId) {
                            return ($m['conversation_id'] ?? '') === $convId;
                        }));
                    }
                }
            }

            sendResponse([
                'success' => true,
                'conversation_id' => $convId,
                'messages' => $messages
            ]);
            break;
        }

        // 2. Get all conversations for a user (buyer or seller)
        if ($action === 'conversations') {
            $userPhone = cleanPhone($_GET['user_phone'] ?? $_GET['phone'] ?? '');
            $userEmail = strtolower(trim($_GET['user_email'] ?? $_GET['email'] ?? ''));
            if (empty($userPhone) && empty($userEmail)) {
                sendResponse(['success' => false, 'error' => 'User phone or email is required'], 400);
            }

            $convList = [];

            if ($pdo) {
                try {
                    if (!empty($userPhone) && !empty($userEmail)) {
                        $stmt = $pdo->prepare("SELECT * FROM `chat_conversations` 
                            WHERE (REPLACE(REPLACE(REPLACE(buyer_phone, ' ', ''), '+', ''), '-', '') LIKE ?) 
                               OR (REPLACE(REPLACE(REPLACE(seller_phone, ' ', ''), '+', ''), '-', '') LIKE ?)
                               OR LOWER(buyer_phone) = ?
                               OR LOWER(seller_phone) = ?
                            ORDER BY `last_message_time` DESC");
                        $stmt->execute(['%' . $userPhone . '%', '%' . $userPhone . '%', $userEmail, $userEmail]);
                    } elseif (!empty($userPhone)) {
                        $stmt = $pdo->prepare("SELECT * FROM `chat_conversations` 
                            WHERE (REPLACE(REPLACE(REPLACE(buyer_phone, ' ', ''), '+', ''), '-', '') LIKE ?) 
                               OR (REPLACE(REPLACE(REPLACE(seller_phone, ' ', ''), '+', ''), '-', '') LIKE ?) 
                            ORDER BY `last_message_time` DESC");
                        $stmt->execute(['%' . $userPhone . '%', '%' . $userPhone . '%']);
                    } else {
                        $stmt = $pdo->prepare("SELECT * FROM `chat_conversations` 
                            WHERE LOWER(buyer_phone) = ? 
                               OR LOWER(seller_phone) = ? 
                            ORDER BY `last_message_time` DESC");
                        $stmt->execute([$userEmail, $userEmail]);
                    }
                    $convList = $stmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {}
            }

            if (empty($convList)) {
                $data = getJsonChats($chatsFile);
                $convList = array_values(array_filter($data['conversations'], function($c) use ($userPhone, $userEmail) {
                    $bP = cleanPhone($c['buyer_phone'] ?? '');
                    $sP = cleanPhone($c['seller_phone'] ?? '');
                    $bRaw = strtolower(trim($c['buyer_phone'] ?? ''));
                    $sRaw = strtolower(trim($c['seller_phone'] ?? ''));
                    if (!empty($userPhone) && (strpos($bP, $userPhone) !== false || strpos($sP, $userPhone) !== false)) {
                        return true;
                    }
                    if (!empty($userEmail) && ($bRaw === $userEmail || $sRaw === $userEmail)) {
                        return true;
                    }
                    return false;
                }));
            }

            sendResponse([
                'success' => true,
                'conversations' => $convList
            ]);
            break;
        }

        // 3. Super Admin view of all conversations
        if ($action === 'admin_all') {
            $allConvs = [];
            $allMsgsCount = 0;

            if ($pdo) {
                try {
                    $stmt = $pdo->query("SELECT * FROM `chat_conversations` ORDER BY `last_message_time` DESC LIMIT 200");
                    $allConvs = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    $mCountStmt = $pdo->query("SELECT COUNT(*) as cnt FROM `chat_messages`");
                    $allMsgsCount = (int)($mCountStmt->fetch(PDO::FETCH_ASSOC)['cnt'] ?? 0);
                } catch (Exception $e) {}
            }

            if (empty($allConvs)) {
                $data = getJsonChats($chatsFile);
                $allConvs = $data['conversations'];
                $allMsgsCount = count($data['messages']);
            }

            sendResponse([
                'success' => true,
                'total_conversations' => count($allConvs),
                'total_messages' => $allMsgsCount,
                'conversations' => $allConvs
            ]);
            break;
        }

        sendResponse(['success' => false, 'error' => 'Invalid GET action'], 400);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $action = $input['action'] ?? $_GET['action'] ?? 'send';

        if ($action === 'send') {
            $propId = trim($input['property_id'] ?? $input['propId'] ?? '');
            $propTitle = trim($input['property_title'] ?? $input['propTitle'] ?? 'Property');
            $buyerName = trim($input['buyer_name'] ?? $input['buyerName'] ?? 'Customer');
            $buyerPhone = trim($input['buyer_phone'] ?? $input['buyerPhone'] ?? ($input['buyer_email'] ?? ''));
            $sellerName = trim($input['seller_name'] ?? $input['sellerName'] ?? 'Owner');
            $sellerPhone = trim($input['seller_phone'] ?? $input['sellerPhone'] ?? ($input['seller_email'] ?? ''));
            $senderPhone = trim($input['sender_phone'] ?? $input['senderPhone'] ?? ($input['sender_email'] ?? $buyerPhone));
            $senderName = trim($input['sender_name'] ?? $input['senderName'] ?? $buyerName);
            $senderRole = trim($input['sender_role'] ?? $input['senderRole'] ?? 'buyer');
            $text = trim($input['message'] ?? $input['text'] ?? '');

            if (empty($text)) {
                sendResponse(['success' => false, 'error' => 'Message text cannot be empty'], 400);
            }
            if (empty($propId)) {
                sendResponse(['success' => false, 'error' => 'Property ID is required'], 400);
            }

            $convId = trim($input['conversation_id'] ?? '');
            $now = date('Y-m-d H:i:s');
            $msgId = 'msg_' . time() . '_' . rand(100, 999);

            // 1. Generate or fetch conversation ID
            $cleanB = cleanPhone($buyerPhone);
            if (empty($cleanB)) $cleanB = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $buyerPhone));
            if (empty($convId)) {
                $convId = 'conv_' . md5($propId . '_' . $cleanB);
            }

            // 2. Save / Update in MySQL
            if ($pdo) {
                try {
                    // Upsert conversation
                    $cStmt = $pdo->prepare("INSERT INTO `chat_conversations` 
                        (`id`, `property_id`, `property_title`, `buyer_name`, `buyer_phone`, `seller_name`, `seller_phone`, `last_message`, `last_message_time`, `created_at`) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) 
                        ON DUPLICATE KEY UPDATE 
                        `last_message` = VALUES(`last_message`), 
                        `last_message_time` = VALUES(`last_message_time`),
                        `buyer_name` = VALUES(`buyer_name`),
                        `seller_name` = VALUES(`seller_name`)");
                    $cStmt->execute([
                        $convId, $propId, $propTitle, $buyerName, $buyerPhone, $sellerName, $sellerPhone, $text, $now, $now
                    ]);

                    // Insert message
                    $mStmt = $pdo->prepare("INSERT INTO `chat_messages` 
                        (`id`, `conversation_id`, `property_id`, `sender_phone`, `sender_name`, `sender_role`, `message`, `is_read`, `created_at`) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)");
                    $mStmt->execute([
                        $msgId, $convId, $propId, $senderPhone, $senderName, $senderRole, $text, $now
                    ]);
                } catch (Exception $e) {}
            }

            // 3. Save / Update in JSON fallback
            $chatData = getJsonChats($chatsFile);
            $foundIdx = -1;
            foreach ($chatData['conversations'] as $idx => $c) {
                if ($c['id'] === $convId) {
                    $foundIdx = $idx;
                    break;
                }
            }

            $convObj = [
                'id' => $convId,
                'property_id' => $propId,
                'property_title' => $propTitle,
                'buyer_name' => $buyerName,
                'buyer_phone' => $buyerPhone,
                'seller_name' => $sellerName,
                'seller_phone' => $sellerPhone,
                'last_message' => $text,
                'last_message_time' => $now,
                'created_at' => ($foundIdx !== -1) ? $chatData['conversations'][$foundIdx]['created_at'] : $now
            ];

            if ($foundIdx !== -1) {
                $chatData['conversations'][$foundIdx] = $convObj;
            } else {
                array_unshift($chatData['conversations'], $convObj);
            }

            $msgObj = [
                'id' => $msgId,
                'conversation_id' => $convId,
                'property_id' => $propId,
                'sender_phone' => $senderPhone,
                'sender_name' => $senderName,
                'sender_role' => $senderRole,
                'message' => $text,
                'is_read' => 0,
                'created_at' => $now
            ];
            $chatData['messages'][] = $msgObj;
            saveJsonChats($chatsFile, $chatData);

            // 4. Log activity for Super Admin
            $actFile = DATA_DIR . '/activities.json';
            $actRaw = file_exists($actFile) ? file_get_contents($actFile) : '[]';
            $actList = json_decode($actRaw, true);
            if (!is_array($actList)) $actList = [];
            $actItem = [
                'id' => 'act_' . time() . '_' . rand(100, 999),
                'user_name' => $senderName,
                'user_phone' => $senderPhone,
                'user_email' => '',
                'action_type' => 'chat_message',
                'action_title' => 'அரட்டை செய்தி அனுப்பப்பட்டது (Chat Message)',
                'property_id' => $propId,
                'property_title' => $propTitle,
                'seller_name' => $sellerName,
                'seller_phone' => $sellerPhone,
                'amount' => 0.0,
                'details' => $text,
                'created_at' => $now
            ];
            array_unshift($actList, $actItem);
            file_put_contents($actFile, json_encode(array_slice($actList, 0, 2000), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

            sendResponse([
                'success' => true,
                'message_id' => $msgId,
                'conversation_id' => $convId,
                'message' => $msgObj
            ]);
            break;
        }

        sendResponse(['success' => false, 'error' => 'Invalid POST action'], 400);
        break;

    default:
        sendResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
