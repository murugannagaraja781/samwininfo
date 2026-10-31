<?php
// ==========================================================
// Tenkasi Dreams Land - Live Users & User Management API
// Tracks Active Online Users & Enables Super Admin Direct Messaging
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

$liveUsersFile = DATA_DIR . '/live_users.json';
$adminMsgsFile = DATA_DIR . '/admin_messages.json';
$adViewsFile   = DATA_DIR . '/user_ad_views.json';

function getJsonData($file, $default = []) {
    if (!file_exists($file)) return $default;
    $raw = file_get_contents($file);
    $data = json_decode($raw, true);
    return is_array($data) ? $data : $default;
}

function saveJsonData($file, $data) {
    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

function cleanPhone($phone) {
    return preg_replace('/[^0-9]/', '', (string)$phone);
}

// Auto-create live_users, admin_messages & user_ad_views tables in MySQL if connected
$pdo = getDbConnection();
if ($pdo) {
    try {
        $pdo->exec("CREATE TABLE IF NOT EXISTS `live_users` (
            `id` VARCHAR(64) PRIMARY KEY,
            `user_id` VARCHAR(64) NOT NULL,
            `user_name` VARCHAR(150) NOT NULL,
            `user_phone` VARCHAR(50) DEFAULT '',
            `user_email` VARCHAR(150) DEFAULT '',
            `platform` VARCHAR(50) DEFAULT 'Android App',
            `current_screen` VARCHAR(255) DEFAULT 'Home',
            `role` VARCHAR(50) DEFAULT 'buyer',
            `ip_address` VARCHAR(64) DEFAULT '',
            `last_active` DATETIME NOT NULL,
            `created_at` DATETIME NOT NULL,
            INDEX (`user_id`),
            INDEX (`user_phone`),
            INDEX (`last_active`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        $pdo->exec("CREATE TABLE IF NOT EXISTS `admin_direct_messages` (
            `id` VARCHAR(64) PRIMARY KEY,
            `user_id` VARCHAR(64) DEFAULT '',
            `user_phone` VARCHAR(50) NOT NULL,
            `user_name` VARCHAR(150) DEFAULT '',
            `admin_name` VARCHAR(150) DEFAULT 'Super Admin',
            `title` VARCHAR(255) DEFAULT 'Super Admin செய்தி',
            `message` TEXT NOT NULL,
            `is_broadcast` TINYINT(1) DEFAULT 0,
            `is_read` TINYINT(1) DEFAULT 0,
            `created_at` DATETIME NOT NULL,
            INDEX (`user_phone`),
            INDEX (`user_id`),
            INDEX (`is_broadcast`),
            INDEX (`is_read`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        $pdo->exec("CREATE TABLE IF NOT EXISTS `user_ad_views` (
            `id` VARCHAR(64) PRIMARY KEY,
            `user_id` VARCHAR(64) NOT NULL,
            `user_email` VARCHAR(150) DEFAULT '',
            `user_phone` VARCHAR(50) DEFAULT '',
            `free_ad_limit` INT DEFAULT 3,
            `ads_viewed` INT DEFAULT 0,
            `unlocked_properties` TEXT,
            `is_premium` TINYINT(1) DEFAULT 0,
            `updated_at` DATETIME NOT NULL,
            `created_at` DATETIME NOT NULL,
            INDEX (`user_id`),
            INDEX (`user_email`),
            INDEX (`user_phone`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        // Migration: ensure title and is_broadcast columns exist if table was previously created
        try {
            $pdo->exec("ALTER TABLE `admin_direct_messages` ADD COLUMN `title` VARCHAR(255) DEFAULT 'Super Admin செய்தி' AFTER `admin_name`");
        } catch (Exception $e) {}
        try {
            $pdo->exec("ALTER TABLE `admin_direct_messages` ADD COLUMN `is_broadcast` TINYINT(1) DEFAULT 0 AFTER `message`");
        } catch (Exception $e) {}
    } catch (Exception $e) {
        error_log('Table creation error in users.php: ' . $e->getMessage());
    }
}

function getOrCreateUserAdViews($pdo, $userId, $userEmail, $userPhone) {
    global $adViewsFile;
    $cleanP = cleanPhone($userPhone);
    $limit = defined('FREE_CONTACT_LIMIT') ? FREE_CONTACT_LIMIT : 3;
    $now = date('Y-m-d H:i:s');
    
    // 1. Try DB
    $record = null;
    if ($pdo) {
        try {
            $clauses = [];
            $params = [];
            if (!empty($userId) && $userId !== 'mobile_guest') {
                $clauses[] = "`user_id` = ?";
                $params[] = $userId;
            }
            if (!empty($userEmail)) {
                $clauses[] = "`user_email` = ?";
                $params[] = $userEmail;
            }
            if (!empty($cleanP)) {
                $clauses[] = "REPLACE(REPLACE(REPLACE(user_phone, ' ', ''), '+', ''), '-', '') LIKE ?";
                $params[] = '%' . $cleanP . '%';
            }
            if (!empty($clauses)) {
                $stmt = $pdo->prepare("SELECT * FROM `user_ad_views` WHERE (" . implode(' OR ', $clauses) . ") LIMIT 1");
                $stmt->execute($params);
                $record = $stmt->fetch(PDO::FETCH_ASSOC);
            }
        } catch (Exception $e) {}
    }

    // 2. Try JSON if not found
    if (!$record) {
        $all = getJsonData($adViewsFile, []);
        foreach ($all as $item) {
            $ip = cleanPhone($item['user_phone'] ?? '');
            $iu = $item['user_id'] ?? '';
            $ie = $item['user_email'] ?? '';
            if ((!empty($userId) && $iu === $userId && $userId !== 'mobile_guest') ||
                (!empty($userEmail) && strcasecmp($ie, $userEmail) === 0) ||
                (!empty($cleanP) && !empty($ip) && $ip === $cleanP)) {
                $record = $item;
                break;
            }
        }
    }

    if (!$record) {
        $id = 'uav_' . (!empty($cleanP) ? $cleanP : (!empty($userId) ? $userId : md5($userEmail . '_' . time())));
        $record = [
            'id' => $id,
            'user_id' => $userId ?: $id,
            'user_email' => $userEmail,
            'user_phone' => $userPhone,
            'free_ad_limit' => $limit,
            'ads_viewed' => 0,
            'unlocked_properties' => json_encode([]),
            'is_premium' => 0,
            'created_at' => $now,
            'updated_at' => $now
        ];

        if ($pdo) {
            try {
                $stmt = $pdo->prepare("INSERT INTO `user_ad_views` 
                    (`id`, `user_id`, `user_email`, `user_phone`, `free_ad_limit`, `ads_viewed`, `unlocked_properties`, `is_premium`, `updated_at`, `created_at`) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $record['id'], $record['user_id'], $record['user_email'], $record['user_phone'],
                    $record['free_ad_limit'], $record['ads_viewed'], $record['unlocked_properties'],
                    $record['is_premium'], $now, $now
                ]);
            } catch (Exception $e) {}
        }

        $all = getJsonData($adViewsFile, []);
        array_unshift($all, $record);
        saveJsonData($adViewsFile, array_slice($all, 0, 5000));
    }

    return $record;
}

function saveUserAdViews($pdo, $record) {
    global $adViewsFile;
    $now = date('Y-m-d H:i:s');
    $record['updated_at'] = $now;

    if ($pdo) {
        try {
            $stmt = $pdo->prepare("UPDATE `user_ad_views` SET 
                `user_email` = ?, 
                `user_phone` = ?, 
                `free_ad_limit` = ?, 
                `ads_viewed` = ?, 
                `unlocked_properties` = ?, 
                `is_premium` = ?, 
                `updated_at` = ? 
                WHERE `id` = ?");
            $stmt->execute([
                $record['user_email'] ?? '',
                $record['user_phone'] ?? '',
                (int)($record['free_ad_limit'] ?? 3),
                (int)($record['ads_viewed'] ?? 0),
                is_string($record['unlocked_properties']) ? $record['unlocked_properties'] : json_encode($record['unlocked_properties']),
                (int)($record['is_premium'] ?? 0),
                $now,
                $record['id']
            ]);
        } catch (Exception $e) {}
    }

    $all = getJsonData($adViewsFile, []);
    $found = false;
    foreach ($all as &$item) {
        if (($item['id'] ?? '') === $record['id']) {
            $item = $record;
            $found = true;
            break;
        }
    }
    if (!$found) {
        array_unshift($all, $record);
    }
    saveJsonData($adViewsFile, array_slice($all, 0, 5000));
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$action = $_GET['action'] ?? ($_POST['action'] ?? 'list_live');

switch ($method) {
    case 'GET':
        // 1. List Live Users for Super Admin
        if ($action === 'list_live' || $action === 'list') {
            $liveUsers = [];
            $now = time();

            if ($pdo) {
                try {
                    $stmt = $pdo->query("SELECT * FROM `live_users` ORDER BY `last_active` DESC LIMIT 300");
                    $liveUsers = $stmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {}
            }

            if (empty($liveUsers)) {
                $liveUsers = getJsonData($liveUsersFile, []);
                usort($liveUsers, function($a, $b) {
                    return strtotime($b['last_active'] ?? '0') <=> strtotime($a['last_active'] ?? '0');
                });
            }

            $activeNowCount = 0;
            $appUsersCount = 0;
            $webUsersCount = 0;
            $formattedUsers = [];

            foreach ($liveUsers as $u) {
                $lastActiveTime = strtotime($u['last_active'] ?? '0');
                $diffSec = $now - $lastActiveTime;

                // Status calculation:
                // <= 180s (3 mins) -> Online
                // <= 900s (15 mins) -> Idle
                // > 900s -> Offline
                $status = 'offline';
                $isOnline = false;
                if ($diffSec <= 180) {
                    $status = 'online';
                    $isOnline = true;
                    $activeNowCount++;
                } elseif ($diffSec <= 900) {
                    $status = 'idle';
                }

                $platform = $u['platform'] ?? 'Android App';
                if (stripos($platform, 'web') !== false) {
                    if ($isOnline) $webUsersCount++;
                } else {
                    if ($isOnline) $appUsersCount++;
                }

                $formattedUsers[] = [
                    'id' => $u['id'] ?? ('user_' . rand(100, 999)),
                    'user_id' => $u['user_id'] ?? '',
                    'user_name' => $u['user_name'] ?? 'Customer',
                    'user_phone' => $u['user_phone'] ?? '',
                    'user_email' => $u['user_email'] ?? '',
                    'platform' => $platform,
                    'current_screen' => $u['current_screen'] ?? 'Home',
                    'role' => $u['role'] ?? 'buyer',
                    'last_active' => $u['last_active'] ?? date('Y-m-d H:i:s'),
                    'last_active_diff' => $diffSec,
                    'status' => $status,
                    'is_online' => $isOnline
                ];
            }

            sendResponse([
                'success' => true,
                'stats' => [
                    'active_now' => $activeNowCount,
                    'app_active' => $appUsersCount,
                    'web_active' => $webUsersCount,
                    'total_users' => count($formattedUsers)
                ],
                'users' => $formattedUsers,
                'server_time' => date('Y-m-d H:i:s')
            ]);
            break;
        }

        // 2. Fetch admin messages for a specific user
        if ($action === 'get_admin_messages') {
            $userPhone = cleanPhone($_GET['user_phone'] ?? '');
            $userId = trim($_GET['user_id'] ?? '');
            $messages = [];

            if ($pdo && (!empty($userPhone) || !empty($userId))) {
                try {
                    $stmt = $pdo->prepare("SELECT * FROM `admin_direct_messages` 
                        WHERE (REPLACE(REPLACE(REPLACE(user_phone, ' ', ''), '+', ''), '-', '') LIKE ?) 
                           OR (`user_id` = ? AND `user_id` != '') 
                        ORDER BY `created_at` DESC LIMIT 50");
                    $stmt->execute(['%' . $userPhone . '%', $userId]);
                    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {}
            }

            if (empty($messages)) {
                $allMsgs = getJsonData($adminMsgsFile, []);
                $messages = array_values(array_filter($allMsgs, function($m) use ($userPhone, $userId) {
                    $p = cleanPhone($m['user_phone'] ?? '');
                    return (!empty($userPhone) && strpos($p, $userPhone) !== false) || (!empty($userId) && ($m['user_id'] ?? '') === $userId);
                }));
            }

            sendResponse([
                'success' => true,
                'messages' => $messages
            ]);
            break;
        }

        // 3. Get User Ad Access / Contact View Limit Status
        if ($action === 'get_ad_access') {
            $userId = trim($_GET['user_id'] ?? '');
            $userEmail = trim($_GET['user_email'] ?? '');
            $userPhone = cleanPhone($_GET['user_phone'] ?? '');
            $propId = trim($_GET['property_id'] ?? '');

            $record = getOrCreateUserAdViews($pdo, $userId, $userEmail, $userPhone);

            $unlocked = [];
            if (!empty($record['unlocked_properties'])) {
                $decoded = is_array($record['unlocked_properties']) ? $record['unlocked_properties'] : json_decode($record['unlocked_properties'], true);
                if (is_array($decoded)) $unlocked = $decoded;
            }

            $limit = (int)($record['free_ad_limit'] ?? 3);
            $viewed = (int)($record['ads_viewed'] ?? 0);
            $isPremium = !empty($record['is_premium']);
            $isUnlocked = (!empty($propId) && in_array($propId, $unlocked));
            $remaining = max(0, $limit - $viewed);

            $canView = $isPremium || $isUnlocked || ($remaining > 0);

            sendResponse([
                'success' => true,
                'user_id' => $record['user_id'],
                'ads_viewed' => $viewed,
                'free_ad_limit' => $limit,
                'remaining_free' => $remaining,
                'can_view' => $canView,
                'is_premium' => $isPremium,
                'already_unlocked' => $isUnlocked,
                'unlocked_properties' => $unlocked
            ]);
            break;
        }

        sendResponse(['success' => false, 'error' => 'Invalid GET action'], 400);
        break;

    case 'POST':
        $rawInput = file_get_contents('php://input');
        $input = json_decode($rawInput, true) ?? $_POST;
        $postAction = $input['action'] ?? $_GET['action'] ?? 'heartbeat';

        // 1. Heartbeat / Ping from App or Web
        if ($postAction === 'heartbeat' || $postAction === 'ping') {
            $userId = trim($input['user_id'] ?? $input['userId'] ?? '');
            $userName = trim($input['user_name'] ?? $input['userName'] ?? 'Customer');
            $userPhone = trim($input['user_phone'] ?? $input['userPhone'] ?? '');
            $userEmail = trim($input['user_email'] ?? $input['userEmail'] ?? '');
            $platform = trim($input['platform'] ?? 'Android App');
            $currentScreen = trim($input['current_screen'] ?? $input['currentScreen'] ?? 'Home');
            $role = trim($input['role'] ?? 'buyer');
            $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '';
            $now = date('Y-m-d H:i:s');

            // Unique record key per user or phone
            $cleanP = cleanPhone($userPhone);
            $recordId = !empty($cleanP) ? ('live_' . $cleanP) : (!empty($userId) ? ('live_' . $userId) : ('live_guest_' . md5($ipAddress . '_' . $platform)));

            $userRecord = [
                'id' => $recordId,
                'user_id' => $userId,
                'user_name' => $userName,
                'user_phone' => $userPhone,
                'user_email' => $userEmail,
                'platform' => $platform,
                'current_screen' => $currentScreen,
                'role' => $role,
                'ip_address' => $ipAddress,
                'last_active' => $now,
                'created_at' => $now
            ];

            // 1. Upsert into MySQL
            if ($pdo) {
                try {
                    $stmt = $pdo->prepare("INSERT INTO `live_users` 
                        (`id`, `user_id`, `user_name`, `user_phone`, `user_email`, `platform`, `current_screen`, `role`, `ip_address`, `last_active`, `created_at`) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) 
                        ON DUPLICATE KEY UPDATE 
                        `user_name` = VALUES(`user_name`), 
                        `user_email` = VALUES(`user_email`), 
                        `platform` = VALUES(`platform`), 
                        `current_screen` = VALUES(`current_screen`), 
                        `role` = VALUES(`role`), 
                        `last_active` = VALUES(`last_active`)");
                    $stmt->execute([
                        $recordId, $userId, $userName, $userPhone, $userEmail, $platform, $currentScreen, $role, $ipAddress, $now, $now
                    ]);
                } catch (Exception $e) {
                    error_log('Live user MySQL update error: ' . $e->getMessage());
                }
            }

            // 2. Upsert into JSON
            $allUsers = getJsonData($liveUsersFile, []);
            $foundIndex = -1;
            foreach ($allUsers as $idx => $u) {
                if (($u['id'] ?? '') === $recordId || (!empty($cleanP) && cleanPhone($u['user_phone'] ?? '') === $cleanP)) {
                    $foundIndex = $idx;
                    break;
                }
            }
            if ($foundIndex !== -1) {
                $userRecord['created_at'] = $allUsers[$foundIndex]['created_at'] ?? $now;
                $allUsers[$foundIndex] = $userRecord;
            } else {
                array_unshift($allUsers, $userRecord);
            }
            if (count($allUsers) > 1000) {
                $allUsers = array_slice($allUsers, 0, 1000);
            }
            saveJsonData($liveUsersFile, $allUsers);

            // 3. Check for any unread admin messages for this user (direct or broadcast)
            $unreadAdminMsgs = [];
            $lastBroadcastId = trim($input['last_broadcast_id'] ?? '');

            if ($pdo) {
                try {
                    $clauses = [];
                    $params = [];

                    if (!empty($cleanP)) {
                        $clauses[] = "(REPLACE(REPLACE(REPLACE(user_phone, ' ', ''), '+', ''), '-', '') LIKE ?)";
                        $params[] = '%' . $cleanP . '%';
                    }
                    if (!empty($userId) && $userId !== 'mobile_guest') {
                        $clauses[] = "(`user_id` = ?)";
                        $params[] = $userId;
                    }
                    if (!empty($userEmail)) {
                        $clauses[] = "(`user_email` = ? OR `user_id` = ?)";
                        $params[] = $userEmail;
                        $params[] = $userEmail;
                    }
                    // Broadcasts
                    $clauses[] = "(`user_phone` = 'ALL' OR `user_id` = 'ALL' OR `is_broadcast` = 1)";

                    $sql = "SELECT * FROM `admin_direct_messages` 
                            WHERE (" . implode(' OR ', $clauses) . ") 
                              AND `is_read` = 0 
                            ORDER BY `created_at` ASC LIMIT 20";
                    $mStmt = $pdo->prepare($sql);
                    $mStmt->execute($params);
                    $unreadAdminMsgs = $mStmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {}
            }

            if (empty($unreadAdminMsgs)) {
                $allMsgs = getJsonData($adminMsgsFile, []);
                $unreadAdminMsgs = array_values(array_filter($allMsgs, function($m) use ($cleanP, $userId, $userEmail) {
                    if (!empty($m['is_read'])) return false;
                    $p = cleanPhone($m['user_phone'] ?? '');
                    $u = $m['user_id'] ?? '';
                    $e = $m['user_email'] ?? '';
                    $isBroadcast = !empty($m['is_broadcast']) || ($m['user_phone'] ?? '') === 'ALL' || ($m['user_id'] ?? '') === 'ALL';
                    if ($isBroadcast) return true;
                    if (!empty($cleanP) && $p === $cleanP) return true;
                    if (!empty($userId) && $userId !== 'mobile_guest' && $u === $userId) return true;
                    if (!empty($userEmail) && (strcasecmp($e, $userEmail) === 0 || strcasecmp($u, $userEmail) === 0)) return true;
                    return false;
                }));
            }

            // Filter out broadcasts already seen by this client
            if (!empty($lastBroadcastId)) {
                $unreadAdminMsgs = array_values(array_filter($unreadAdminMsgs, function($m) use ($lastBroadcastId) {
                    $mId = $m['id'] ?? '';
                    if (str_starts_with($mId, 'broad_') && strcmp($mId, $lastBroadcastId) <= 0) {
                        return false;
                    }
                    return true;
                }));
            }

            sendResponse([
                'success' => true,
                'status' => 'online',
                'server_time' => $now,
                'unread_admin_messages' => $unreadAdminMsgs
            ]);
            break;
        }

        // 2. Super Admin Sends Direct Message to User
        if ($postAction === 'send_admin_message') {
            $userPhone = trim($input['user_phone'] ?? $input['userPhone'] ?? '');
            $userId = trim($input['user_id'] ?? $input['userId'] ?? '');
            $userEmail = trim($input['user_email'] ?? $input['userEmail'] ?? '');
            $userName = trim($input['user_name'] ?? $input['userName'] ?? 'Customer');
            $adminName = trim($input['admin_name'] ?? $input['adminName'] ?? 'Super Admin');
            $title = trim($input['title'] ?? 'Super Admin செய்தி');
            $message = trim($input['message'] ?? $input['text'] ?? '');

            if (empty($message)) {
                sendResponse(['success' => false, 'error' => 'Message cannot be empty'], 400);
            }
            if (empty($userPhone) && empty($userId) && empty($userEmail)) {
                sendResponse(['success' => false, 'error' => 'User phone, ID, or Email is required'], 400);
            }

            $msgId = 'adm_msg_' . time() . '_' . rand(100, 999);
            $now = date('Y-m-d H:i:s');

            $msgRecord = [
                'id' => $msgId,
                'user_id' => $userId,
                'user_phone' => $userPhone,
                'user_email' => $userEmail,
                'user_name' => $userName,
                'admin_name' => $adminName,
                'title' => $title,
                'message' => $message,
                'is_broadcast' => 0,
                'is_read' => 0,
                'created_at' => $now
            ];

            // Save in MySQL
            if ($pdo) {
                try {
                    $stmt = $pdo->prepare("INSERT INTO `admin_direct_messages` 
                        (`id`, `user_id`, `user_phone`, `user_name`, `admin_name`, `title`, `message`, `is_broadcast`, `is_read`, `created_at`) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, ?)");
                    $stmt->execute([$msgId, $userId, $userPhone, $userName, $adminName, $title, $message, $now]);
                } catch (Exception $e) {}
            }

            // Save in JSON
            $allMsgs = getJsonData($adminMsgsFile, []);
            array_unshift($allMsgs, $msgRecord);
            if (count($allMsgs) > 1000) $allMsgs = array_slice($allMsgs, 0, 1000);
            saveJsonData($adminMsgsFile, $allMsgs);

            // Also log in user activities so Super Admin sees it in timeline
            $actFile = DATA_DIR . '/activities.json';
            $allActs = getJsonData($actFile, []);
            array_unshift($allActs, [
                'id' => 'act_' . time() . '_' . rand(100, 999),
                'user_name' => $userName,
                'user_phone' => $userPhone,
                'user_email' => $userEmail,
                'action_type' => 'admin_direct_message',
                'action_title' => '🛡️ அட்மின் நேரடி செய்தி அனுப்பப்பட்டது (Admin Message)',
                'property_id' => '',
                'property_title' => 'Direct Message to ' . $userName,
                'seller_name' => $adminName,
                'seller_phone' => 'Super Admin',
                'amount' => 0.0,
                'details' => $message,
                'created_at' => $now
            ]);
            saveJsonData($actFile, array_slice($allActs, 0, 2000));

            sendResponse([
                'success' => true,
                'message' => 'செய்தி வெற்றிகரமாக பயனருக்கு அனுப்பப்பட்டது (Message sent to user)',
                'data' => $msgRecord
            ]);
            break;
        }

        // 3. Super Admin Sends Broadcast / Bulk Push Notification to ALL Users
        if ($postAction === 'broadcast_message' || $postAction === 'send_broadcast') {
            $title = trim($input['title'] ?? '📢 சூப்பர் அட்மின் பொது அறிவிப்பு');
            $message = trim($input['message'] ?? $input['text'] ?? '');
            $adminName = trim($input['admin_name'] ?? $input['adminName'] ?? 'Super Admin');

            if (empty($message)) {
                sendResponse(['success' => false, 'error' => 'Message cannot be empty'], 400);
            }

            $broadcastId = 'broad_' . time() . '_' . rand(100, 999);
            $now = date('Y-m-d H:i:s');

            $broadcastRecord = [
                'id' => $broadcastId,
                'user_id' => 'ALL',
                'user_phone' => 'ALL',
                'user_name' => 'அனைத்து பயனர்கள் (All Users)',
                'admin_name' => $adminName,
                'title' => $title,
                'message' => $message,
                'is_broadcast' => 1,
                'is_read' => 0,
                'created_at' => $now
            ];

            // Save in MySQL
            if ($pdo) {
                try {
                    $stmt = $pdo->prepare("INSERT INTO `admin_direct_messages` 
                        (`id`, `user_id`, `user_phone`, `user_name`, `admin_name`, `title`, `message`, `is_broadcast`, `is_read`, `created_at`) 
                        VALUES (?, 'ALL', 'ALL', 'All Users', ?, ?, ?, 1, 0, ?)");
                    $stmt->execute([$broadcastId, $adminName, $title, $message, $now]);
                } catch (Exception $e) {}
            }

            // Save in JSON
            $allMsgs = getJsonData($adminMsgsFile, []);
            array_unshift($allMsgs, $broadcastRecord);
            if (count($allMsgs) > 1000) $allMsgs = array_slice($allMsgs, 0, 1000);
            saveJsonData($adminMsgsFile, $allMsgs);

            // Also save into notifications.json so it appears in the Notification screen
            $notifsFile = DATA_DIR . '/notifications.json';
            $allNotifs = getJsonData($notifsFile, []);
            array_unshift($allNotifs, [
                'id' => $broadcastId,
                'type' => 'broadcast',
                'title' => $title,
                'message' => $message,
                'adminName' => $adminName,
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'active'
            ]);
            saveJsonData($notifsFile, array_slice($allNotifs, 0, 1000));

            // Also log in user activities
            $actFile = DATA_DIR . '/activities.json';
            $allActs = getJsonData($actFile, []);
            array_unshift($allActs, [
                'id' => 'act_' . time() . '_' . rand(100, 999),
                'user_name' => 'அனைத்து பயனர்கள்',
                'user_phone' => 'All Users',
                'user_email' => '',
                'action_type' => 'broadcast_notification',
                'action_title' => '📢 பொது புஷ் அறிவிப்பு (Bulk Push Notification)',
                'property_id' => '',
                'property_title' => $title,
                'seller_name' => $adminName,
                'seller_phone' => 'Super Admin',
                'amount' => 0.0,
                'details' => $message,
                'created_at' => $now
            ]);
            saveJsonData($actFile, array_slice($allActs, 0, 2000));

            sendResponse([
                'success' => true,
                'message' => '📢 அறிவிப்பு அனைத்து பயனர்களுக்கும் வெற்றிகரமாக அனுப்பப்பட்டது! (Broadcast sent successfully)',
                'data' => $broadcastRecord
            ]);
            break;
        }

        // 4. Mark Admin Message as Read
        if ($postAction === 'mark_read') {
            $msgId = trim($input['message_id'] ?? $input['msgId'] ?? '');
            if (!empty($msgId) && !str_starts_with($msgId, 'broad_')) {
                if ($pdo) {
                    try {
                        $stmt = $pdo->prepare("UPDATE `admin_direct_messages` SET `is_read` = 1 WHERE `id` = ?");
                        $stmt->execute([$msgId]);
                    } catch (Exception $e) {}
                }
                $allMsgs = getJsonData($adminMsgsFile, []);
                foreach ($allMsgs as &$m) {
                    if (($m['id'] ?? '') === $msgId) {
                        $m['is_read'] = 1;
                        break;
                    }
                }
                saveJsonData($adminMsgsFile, $allMsgs);
            }

            sendResponse(['success' => true]);
            break;
        }

        // 5. Unlock Ad / Contact View (Server-Side Enforced 3-Free-Views Logic)
        if ($postAction === 'unlock_ad') {
            $userId = trim($input['user_id'] ?? $input['userId'] ?? '');
            $userEmail = trim($input['user_email'] ?? $input['userEmail'] ?? '');
            $userPhone = cleanPhone($input['user_phone'] ?? $input['userPhone'] ?? '');
            $propId = trim($input['property_id'] ?? $input['propertyId'] ?? '');
            $paymentId = trim($input['payment_id'] ?? $input['paymentId'] ?? '');

            if (empty($propId)) {
                sendResponse(['success' => false, 'error' => 'Property ID is required'], 400);
            }

            $record = getOrCreateUserAdViews($pdo, $userId, $userEmail, $userPhone);

            $unlocked = [];
            if (!empty($record['unlocked_properties'])) {
                $decoded = is_array($record['unlocked_properties']) ? $record['unlocked_properties'] : json_decode($record['unlocked_properties'], true);
                if (is_array($decoded)) $unlocked = $decoded;
            }

            $limit = (int)($record['free_ad_limit'] ?? 3);
            $viewed = (int)($record['ads_viewed'] ?? 0);
            $isPremium = !empty($record['is_premium']) || !empty($paymentId);

            // If already unlocked, return success immediately
            if (in_array($propId, $unlocked)) {
                sendResponse([
                    'success' => true,
                    'can_view' => true,
                    'already_unlocked' => true,
                    'ads_viewed' => $viewed,
                    'remaining_free' => max(0, $limit - $viewed),
                    'is_premium' => $isPremium,
                    'unlocked_properties' => $unlocked
                ]);
                break;
            }

            // If paid, upgrade or unlock
            if (!empty($paymentId)) {
                $unlocked[] = $propId;
                $record['unlocked_properties'] = json_encode(array_values(array_unique($unlocked)));
                $record['is_premium'] = 1;
                saveUserAdViews($pdo, $record);

                sendResponse([
                    'success' => true,
                    'can_view' => true,
                    'message' => 'Property unlocked via payment',
                    'ads_viewed' => $viewed,
                    'remaining_free' => max(0, $limit - $viewed),
                    'is_premium' => true,
                    'unlocked_properties' => $unlocked
                ]);
                break;
            }

            // Free unlock check
            if ($viewed < $limit || $isPremium) {
                $unlocked[] = $propId;
                $viewed++;
                $record['ads_viewed'] = $viewed;
                $record['unlocked_properties'] = json_encode(array_values(array_unique($unlocked)));
                saveUserAdViews($pdo, $record);

                sendResponse([
                    'success' => true,
                    'can_view' => true,
                    'message' => 'Free contact unlocked successfully',
                    'ads_viewed' => $viewed,
                    'remaining_free' => max(0, $limit - $viewed),
                    'is_premium' => $isPremium,
                    'unlocked_properties' => $unlocked
                ]);
                break;
            } else {
                // Limit reached! Block view and mandate payment
                sendResponse([
                    'success' => false,
                    'can_view' => false,
                    'needs_payment' => true,
                    'error' => 'Free contact view limit (3) reached. Please make payment to view contact details.',
                    'ads_viewed' => $viewed,
                    'remaining_free' => 0,
                    'is_premium' => false,
                    'unlocked_properties' => $unlocked
                ], 200);
                break;
            }
        }

        sendResponse(['success' => false, 'error' => 'Invalid POST action'], 400);
        break;

    default:
        sendResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}
