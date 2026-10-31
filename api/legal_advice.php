<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

function getLegalAdviceData() {
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $pdo->exec("CREATE TABLE IF NOT EXISTS legal_inquiries (
                id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(100),
                phone VARCHAR(20),
                location VARCHAR(150),
                service_type VARCHAR(100),
                notes TEXT,
                status VARCHAR(20) DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )");
            $stmt = $pdo->query("SELECT * FROM legal_inquiries ORDER BY created_at DESC");
            $rows = $stmt->fetchAll();
            if (!empty($rows)) return $rows;
        } catch (Exception $e) {}
    }
    return readJsonStorage('legal_inquiries.json') ?: [];
}

function saveLegalAdviceData($items) {
    writeJsonStorage('legal_inquiries.json', $items);
}

switch ($method) {
    case 'GET':
        $items = getLegalAdviceData();
        sendResponse([
            'success' => true,
            'count' => count($items),
            'inquiries' => array_values($items)
        ]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

        if (empty($input['name']) || empty($input['phone'])) {
            sendResponse(['success' => false, 'message' => 'பெயர் மற்றும் செல்போன் எண் தேவை (Name and Phone required)'], 400);
        }

        $newItem = [
            'id' => 'legal_' . time() . '_' . rand(100, 999),
            'name' => trim($input['name']),
            'phone' => trim($input['phone']),
            'location' => trim($input['location'] ?? 'தென்காசி'),
            'service_type' => trim($input['serviceType'] ?? $input['service_type'] ?? 'பத்திர ஆவண சரிபார்ப்பு'),
            'notes' => trim($input['notes'] ?? $input['description'] ?? ''),
            'status' => 'pending',
            'created_at' => date('Y-m-d H:i:s')
        ];

        // Save to PDO if available
        $pdo = getDbConnection();
        if ($pdo) {
            try {
                $stmt = $pdo->prepare("INSERT INTO legal_inquiries (id, name, phone, location, service_type, notes, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $newItem['id'],
                    $newItem['name'],
                    $newItem['phone'],
                    $newItem['location'],
                    $newItem['service_type'],
                    $newItem['notes'],
                    $newItem['status'],
                    $newItem['created_at']
                ]);
            } catch (Exception $e) {}
        }

        // Always save to JSON file as well
        $items = getLegalAdviceData();
        array_unshift($items, $newItem);
        saveLegalAdviceData($items);

        sendResponse([
            'success' => true,
            'message' => 'உங்கள் வழக்கறிஞர் சட்ட ஆலோசனை கோரிக்கை வெற்றிகரமாக பதிவு செய்யப்பட்டது! சூப்பர் அட்மின் / வழக்கறிஞர் குழு விரைவில் உங்களைத் தொடர்பு கொள்வர்.',
            'inquiry' => $newItem,
            'superAdminPhone' => '+91 98941 74944',
            'superAdminEmail' => 'tenkasidreams@gmail.com'
        ], 201);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
        break;
}
