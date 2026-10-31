<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/events.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$requestsFile = DATA_DIR . '/user_requests.json';

function getRequestsData() {
    global $requestsFile;
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $pdo->exec("CREATE TABLE IF NOT EXISTS user_requests (
                id VARCHAR(64) PRIMARY KEY,
                sender_phone VARCHAR(32) NOT NULL,
                sender_name VARCHAR(100) NOT NULL,
                receiver_phone VARCHAR(32) NOT NULL,
                receiver_name VARCHAR(100) NOT NULL,
                property_id VARCHAR(64) NULL,
                property_title VARCHAR(255) NULL,
                status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
                message TEXT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_sender (sender_phone),
                INDEX idx_receiver (receiver_phone)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            $stmt = $pdo->query("SELECT * FROM user_requests ORDER BY created_at DESC");
            $rows = $stmt->fetchAll();
            if (!empty($rows)) {
                return array_map(function($r) {
                    return [
                        'id' => $r['id'],
                        'senderPhone' => $r['sender_phone'],
                        'senderName' => $r['sender_name'],
                        'receiverPhone' => $r['receiver_phone'],
                        'receiverName' => $r['receiver_name'],
                        'propertyId' => $r['property_id'],
                        'propertyTitle' => $r['property_title'],
                        'status' => $r['status'],
                        'message' => $r['message'],
                        'createdAt' => $r['created_at'],
                        'updatedAt' => $r['updated_at'],
                    ];
                }, $rows);
            }
        } catch (Exception $e) {
            // fallback to JSON
        }
    }

    if (!file_exists($requestsFile)) {
        return [];
    }
    $raw = file_get_contents($requestsFile);
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function saveRequestItem($req) {
    global $requestsFile;
    $createdTime = isset($req['createdAt']) ? date('Y-m-d H:i:s', strtotime($req['createdAt'])) : date('Y-m-d H:i:s');
    $updatedTime = isset($req['updatedAt']) ? date('Y-m-d H:i:s', strtotime($req['updatedAt'])) : date('Y-m-d H:i:s');

    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $pdo->exec("CREATE TABLE IF NOT EXISTS user_requests (
                id VARCHAR(64) PRIMARY KEY,
                sender_phone VARCHAR(32) NOT NULL,
                sender_name VARCHAR(100) NOT NULL,
                receiver_phone VARCHAR(32) NOT NULL,
                receiver_name VARCHAR(100) NOT NULL,
                property_id VARCHAR(64) NULL,
                property_title VARCHAR(255) NULL,
                status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
                message TEXT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_sender (sender_phone),
                INDEX idx_receiver (receiver_phone)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            $stmt = $pdo->prepare("INSERT INTO user_requests (id, sender_phone, sender_name, receiver_phone, receiver_name, property_id, property_title, status, message, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE status = VALUES(status), message = VALUES(message), updated_at = VALUES(updated_at)");
            $stmt->execute([
                $req['id'],
                $req['senderPhone'],
                $req['senderName'],
                $req['receiverPhone'],
                $req['receiverName'],
                $req['propertyId'] ?? null,
                $req['propertyTitle'] ?? null,
                $req['status'] ?? 'pending',
                $req['message'] ?? '',
                $createdTime,
                $updatedTime,
            ]);
        } catch (Exception $e) {
            // Log error
            error_log("user_requests save error: " . $e->getMessage());
        }
    }

    // Always also persist in JSON file storage
    $all = file_exists($requestsFile) ? (json_decode(file_get_contents($requestsFile), true) ?: []) : [];
    $found = false;
    foreach ($all as &$item) {
        if ($item['id'] === $req['id']) {
            $item = array_merge($item, $req, ['updatedAt' => $updatedTime]);
            $found = true;
            break;
        }
    }
    if (!$found) {
        array_unshift($all, $req);
    }
    file_put_contents($requestsFile, json_encode($all, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    return true;
}

function addAppNotification($notif) {
    $notifsFile = DATA_DIR . '/notifications.json';
    $notifications = file_exists($notifsFile) ? (json_decode(file_get_contents($notifsFile), true) ?: []) : [];
    array_unshift($notifications, $notif);
    if (count($notifications) > 200) {
        $notifications = array_slice($notifications, 0, 200);
    }
    file_put_contents($notifsFile, json_encode($notifications, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

switch ($method) {
    case 'GET':
        $userPhone = $_GET['user_phone'] ?? '';
        $cleanPhone = normalizePhone($userPhone);
        $all = getRequestsData();

        if (empty($cleanPhone)) {
            sendResponse(['success' => true, 'requests' => $all]);
        }

        $sent = [];
        $received = [];

        foreach ($all as $req) {
            $sPhone = normalizePhone($req['senderPhone'] ?? '');
            $rPhone = normalizePhone($req['receiverPhone'] ?? '');

            if ($sPhone === $cleanPhone) {
                $sent[] = $req;
            }
            if ($rPhone === $cleanPhone) {
                $received[] = $req;
            }
        }

        sendResponse([
            'success' => true,
            'sent' => $sent,
            'received' => $received,
            'total' => count($sent) + count($received),
        ]);
        break;

    case 'POST':
        $action = $_GET['action'] ?? '';
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        if (empty($action) && isset($input['action'])) {
            $action = $input['action'];
        }

        // 1. Send Request (User A -> User B)
        if ($action === 'send') {
            $senderPhone = trim($input['senderPhone'] ?? '');
            $senderName = trim($input['senderName'] ?? 'Buyer');
            $receiverPhone = trim($input['receiverPhone'] ?? '');
            $receiverName = trim($input['receiverName'] ?? 'Owner');
            $propertyId = $input['propertyId'] ?? null;
            $propertyTitle = $input['propertyTitle'] ?? 'Property';
            $message = trim($input['message'] ?? 'வணக்கம், உங்கள் விளம்பரம் தொடர்பாக விபரம் அறிய விரும்புகிறேன்.');

            if (empty($senderPhone) || empty($receiverPhone)) {
                sendResponse(['success' => false, 'message' => 'senderPhone and receiverPhone are required'], 400);
            }

            $requestId = 'req_' . time() . '_' . bin2hex(random_bytes(3));
            $newReq = [
                'id' => $requestId,
                'senderPhone' => $senderPhone,
                'senderName' => $senderName,
                'receiverPhone' => $receiverPhone,
                'receiverName' => $receiverName,
                'propertyId' => $propertyId,
                'propertyTitle' => $propertyTitle,
                'status' => 'pending',
                'message' => $message,
                'createdAt' => date('c'),
                'updatedAt' => date('c'),
            ];

            saveRequestItem($newReq);

            // Emit real-time SSE push to receiver
            emitRealtimeEvent($receiverPhone, 'new_request', $newReq);

            // Add notification for receiver
            addAppNotification([
                'id' => 'notif_' . time() . '_' . rand(100, 999),
                'type' => 'enquiry',
                'title' => "புதிய தொடர்பு கோரிக்கை: {$senderName}",
                'message' => "{$senderName} ({$senderPhone}) உங்கள் '{$propertyTitle}' விளம்பரத்திற்கு தொடர்பு கோரிக்கை விடுத்துள்ளார்.",
                'propertyId' => $propertyId,
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'pending',
            ]);

            sendResponse([
                'success' => true,
                'message' => 'கோரிக்கை அனுப்பப்பட்டது (Request sent successfully)',
                'request' => $newReq,
            ]);
        }

        // 2. Accept Request (User B accepts User A's request)
        if ($action === 'accept') {
            $requestId = $input['requestId'] ?? $input['id'] ?? '';
            if (empty($requestId)) {
                sendResponse(['success' => false, 'message' => 'requestId is required'], 400);
            }

            $all = getRequestsData();
            $targetReq = null;
            foreach ($all as $item) {
                if ($item['id'] === $requestId) {
                    $targetReq = $item;
                    break;
                }
            }

            if (!$targetReq) {
                sendResponse(['success' => false, 'message' => 'Request not found'], 404);
            }

            $targetReq['status'] = 'accepted';
            $targetReq['updatedAt'] = date('c');
            saveRequestItem($targetReq);

            // Emit real-time SSE push to sender (User A)
            emitRealtimeEvent($targetReq['senderPhone'], 'request_status_updated', [
                'id' => $requestId,
                'status' => 'accepted',
                'propertyId' => $targetReq['propertyId'],
                'propertyTitle' => $targetReq['propertyTitle'],
                'receiverName' => $targetReq['receiverName'],
                'receiverPhone' => $targetReq['receiverPhone'],
                'message' => "உங்கள் கோரிக்கை ஏற்கப்பட்டது (Accepted by {$targetReq['receiverName']})",
                'updatedAt' => date('c'),
            ]);

            // Add notification for sender
            addAppNotification([
                'id' => 'notif_' . time() . '_' . rand(100, 999),
                'type' => 'ad_approved',
                'title' => "கோரிக்கை ஏற்கப்பட்டது! (Request Accepted)",
                'message' => "{$targetReq['receiverName']} உங்கள் '{$targetReq['propertyTitle']}' கோரிக்கையை ஏற்றுக்கொண்டுள்ளார். தொடர்பு எண்: {$targetReq['receiverPhone']}",
                'propertyId' => $targetReq['propertyId'],
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'active',
            ]);

            sendResponse([
                'success' => true,
                'status' => 'accepted',
                'message' => 'கோரிக்கை ஏற்கப்பட்டது (Request accepted)',
                'request' => $targetReq,
            ]);
        }

        // 3. Reject Request (User B rejects User A's request)
        if ($action === 'reject') {
            $requestId = $input['requestId'] ?? $input['id'] ?? '';
            if (empty($requestId)) {
                sendResponse(['success' => false, 'message' => 'requestId is required'], 400);
            }

            $all = getRequestsData();
            $targetReq = null;
            foreach ($all as $item) {
                if ($item['id'] === $requestId) {
                    $targetReq = $item;
                    break;
                }
            }

            if (!$targetReq) {
                sendResponse(['success' => false, 'message' => 'Request not found'], 404);
            }

            $targetReq['status'] = 'rejected';
            $targetReq['updatedAt'] = date('c');
            saveRequestItem($targetReq);

            // Emit real-time SSE push to sender (User A)
            emitRealtimeEvent($targetReq['senderPhone'], 'request_status_updated', [
                'id' => $requestId,
                'status' => 'rejected',
                'propertyId' => $targetReq['propertyId'],
                'propertyTitle' => $targetReq['propertyTitle'],
                'receiverName' => $targetReq['receiverName'],
                'message' => "உங்கள் கோரிக்கை நிராகரிக்கப்பட்டது (Declined by {$targetReq['receiverName']})",
                'updatedAt' => date('c'),
            ]);

            // Add notification for sender
            addAppNotification([
                'id' => 'notif_' . time() . '_' . rand(100, 999),
                'type' => 'system',
                'title' => "கோரிக்கை நிராகரிக்கப்பட்டது (Request Declined)",
                'message' => "{$targetReq['receiverName']} உங்கள் '{$targetReq['propertyTitle']}' கோரிக்கையை நிராகரித்துள்ளார்.",
                'propertyId' => $targetReq['propertyId'],
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'rejected',
            ]);

            sendResponse([
                'success' => true,
                'status' => 'rejected',
                'message' => 'கோரிக்கை நிராகரிக்கப்பட்டது (Request declined)',
                'request' => $targetReq,
            ]);
        }

        sendResponse(['success' => false, 'message' => 'Invalid action'], 400);
        break;
}
