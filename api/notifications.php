<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$notifsFile = DATA_DIR . '/notifications.json';

function getNotificationsData($file) {
    if (!file_exists($file)) {
        return [];
    }
    $raw = file_get_contents($file);
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function saveNotificationsData($file, $data) {
    file_put_contents($file, json_encode(array_values($data), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

switch ($method) {
    case 'GET':
        $notifications = getNotificationsData($notifsFile);
        
        // Count unread and pending
        $unreadCount = 0;
        $pendingCount = 0;
        foreach ($notifications as $n) {
            if (empty($n['isRead'])) $unreadCount++;
            if (($n['status'] ?? '') === 'pending') $pendingCount++;
        }

        // Return sorted by timestamp desc
        usort($notifications, function($a, $b) {
            return strcmp($b['timestamp'] ?? '', $a['timestamp'] ?? '');
        });

        sendResponse([
            'success' => true,
            'unreadCount' => $unreadCount,
            'pendingCount' => $pendingCount,
            'total' => count($notifications),
            'notifications' => $notifications
        ]);
        break;

    case 'POST':
        $action = $_GET['action'] ?? '';
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        if (empty($action) && isset($input['action'])) {
            $action = $input['action'];
        }

        $notifications = getNotificationsData($notifsFile);

        if ($action === 'mark_read') {
            $targetId = $input['id'] ?? $_GET['id'] ?? null;
            foreach ($notifications as &$n) {
                if (!$targetId || $targetId === 'all' || $n['id'] === $targetId) {
                    $n['isRead'] = true;
                }
            }
            saveNotificationsData($notifsFile, $notifications);
            sendResponse([
                'success' => true,
                'message' => 'அறிவிப்புகள் படிக்கப்பட்டதாக குறிக்கப்பட்டன (Marked as read)'
            ]);
            break;
        }

        if ($action === 'clear') {
            $notifications = [];
            saveNotificationsData($notifsFile, $notifications);
            sendResponse([
                'success' => true,
                'message' => 'அறிவிப்புகள் அழிக்கப்பட்டன (Notifications cleared)'
            ]);
            break;
        }

        if ($action === 'create') {
            $newNotif = [
                'id' => 'notif_' . time() . '_' . rand(100, 999),
                'type' => $input['type'] ?? 'new_property_ad',
                'title' => trim($input['title'] ?? 'புதிய விளம்பரம் பதிவிடப்பட்டுள்ளது'),
                'message' => trim($input['message'] ?? 'புதிய பயனர் விளம்பரம் சரிபார்ப்பிற்காக வந்துள்ளது'),
                'propertyId' => $input['propertyId'] ?? null,
                'propertyTitle' => $input['propertyTitle'] ?? '',
                'sellerName' => $input['sellerName'] ?? '',
                'sellerPhone' => $input['sellerPhone'] ?? '',
                'price' => $input['price'] ?? 0,
                'propertyType' => $input['propertyType'] ?? 'Land',
                'location' => $input['location'] ?? '',
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'pending'
            ];

            array_unshift($notifications, $newNotif);
            saveNotificationsData($notifsFile, $notifications);

            sendResponse([
                'success' => true,
                'message' => 'அறிவிப்பு உருவாக்கப்பட்டது',
                'notification' => $newNotif
            ], 201);
            break;
        }

        if ($action === 'broadcast') {
            $newNotif = [
                'id' => 'broad_' . time() . '_' . rand(100, 999),
                'type' => 'broadcast',
                'title' => trim($input['title'] ?? '📢 சூப்பர் அட்மின் பொது அறிவிப்பு'),
                'message' => trim($input['message'] ?? ''),
                'adminName' => trim($input['adminName'] ?? $input['admin_name'] ?? 'Super Admin'),
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'active'
            ];

            array_unshift($notifications, $newNotif);
            saveNotificationsData($notifsFile, array_slice($notifications, 0, 1000));

            sendResponse([
                'success' => true,
                'message' => 'பொது அறிவிப்பு வெற்றிகரமாக உருவாக்கப்பட்டது',
                'notification' => $newNotif
            ], 201);
            break;
        }

        sendResponse(['success' => false, 'message' => 'Invalid action'], 400);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}
