<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

function getRequirementsData() {
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->query("SELECT * FROM buyer_requirements ORDER BY posted_date DESC");
            return $stmt->fetchAll();
        } catch (Exception $e) {}
    }
    return readJsonStorage('requirements.json');
}

function saveRequirementsData($reqs) {
    writeJsonStorage('requirements.json', $reqs);
}

switch ($method) {
    case 'GET':
        $reqs = getRequirementsData();
        
        if (!empty($_GET['status']) && $_GET['status'] !== 'all') {
            $status = strtolower($_GET['status']);
            $reqs = array_filter($reqs, function($r) use ($status) {
                return strtolower($r['status'] ?? '') === $status;
            });
        }

        if (!empty($_GET['query'])) {
            $q = strtolower(trim($_GET['query']));
            $reqs = array_filter($reqs, function($r) use ($q) {
                return str_contains(strtolower($r['userName'] ?? ''), $q) ||
                       str_contains(strtolower($r['targetLocation'] ?? ''), $q) ||
                       str_contains(strtolower($r['propertyType'] ?? ''), $q) ||
                       str_contains(strtolower($r['description'] ?? ''), $q);
            });
        }

        sendResponse([
            'success' => true,
            'count' => count($reqs),
            'requirements' => array_values($reqs)
        ]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        
        if (empty($input['userName']) || empty($input['userPhone'])) {
            sendResponse(['success' => false, 'message' => 'பெயர் மற்றும் தொலைபேசி எண் தேவை (Name and Phone are required)'], 400);
        }

        $reqs = getRequirementsData();
        $newReq = [
            'id' => 'req_' . time() . '_' . rand(100, 999),
            'userName' => trim($input['userName']),
            'userPhone' => trim($input['userPhone']),
            'propertyType' => trim($input['propertyType'] ?? 'Land'),
            'targetLocation' => trim($input['targetLocation'] ?? 'Tenkasi'),
            'budgetMin' => (float)($input['budgetMin'] ?? 0),
            'budgetMax' => (float)($input['budgetMax'] ?? 0),
            'preferredSize' => trim($input['preferredSize'] ?? ''),
            'facingPreference' => trim($input['facingPreference'] ?? 'Any'),
            'description' => trim($input['description'] ?? ''),
            'postedDate' => date('c'),
            'status' => trim($input['status'] ?? 'active')
        ];

        array_unshift($reqs, $newReq);
        saveRequirementsData($reqs);

        sendResponse([
            'success' => true,
            'message' => 'வாடிக்கையாளர் தேவை வெற்றிகரமாக பதிவு செய்யப்பட்டது! (Requirement saved successfully)',
            'requirement' => $newReq
        ], 201);
        break;

    case 'PUT':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $id = $input['id'] ?? $_GET['id'] ?? null;

        if (!$id) {
            sendResponse(['success' => false, 'message' => 'Requirement ID is required'], 400);
        }

        $reqs = getRequirementsData();
        $found = false;

        foreach ($reqs as $idx => $r) {
            if ($r['id'] == $id) {
                foreach ($input as $k => $v) {
                    if ($k !== 'id') {
                        $reqs[$idx][$k] = $v;
                    }
                }
                $found = true;
                break;
            }
        }

        if (!$found) {
            sendResponse(['success' => false, 'message' => 'Requirement not found'], 404);
        }

        saveRequirementsData($reqs);

        sendResponse([
            'success' => true,
            'message' => 'தேவை விபரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது! (Requirement updated)',
            'requirements' => $reqs
        ]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) {
            $input = json_decode(file_get_contents('php://input'), true);
            $id = $input['id'] ?? null;
        }

        if (!$id) {
            sendResponse(['success' => false, 'message' => 'Requirement ID is required'], 400);
        }

        $reqs = getRequirementsData();
        $initial = count($reqs);
        $reqs = array_filter($reqs, function($r) use ($id) {
            return $r['id'] != $id;
        });

        if (count($reqs) === $initial) {
            sendResponse(['success' => false, 'message' => 'Requirement not found'], 404);
        }

        saveRequirementsData(array_values($reqs));

        sendResponse([
            'success' => true,
            'message' => 'தேவை விபரம் நீக்கப்பட்டது! (Requirement deleted)'
        ]);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}
