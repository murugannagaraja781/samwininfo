<?php
require_once __DIR__ . '/config.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$activitiesFile = DATA_DIR . '/activities.json';

// Helper to get activities from JSON fallback
function getJsonActivities($file) {
    if (!file_exists($file)) {
        return [];
    }
    $raw = file_get_contents($file);
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

// Helper to save activities to JSON
function saveJsonActivities($file, $data) {
    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

switch ($method) {
    case 'GET':
        $pdo = getDbConnection();
        $sellerPhone = trim($_GET['seller_phone'] ?? '');
        $sellerId = trim($_GET['seller_id'] ?? '');
        $userPhone = trim($_GET['user_phone'] ?? '');
        $userEmail = trim($_GET['user_email'] ?? '');
        $userId = trim($_GET['user_id'] ?? '');
        $search = trim($_GET['search'] ?? '');
        $actionType = trim($_GET['action_type'] ?? '');
        $singleUser = trim($_GET['single_user'] ?? '');
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 200;

        $activities = [];

        if ($pdo) {
            try {
                $where = [];
                $params = [];

                $sellerPhoneClean = !empty($sellerPhone) ? preg_replace('/[^0-9]/', '', $sellerPhone) : '';
                if (!empty($sellerPhoneClean)) {
                    $where[] = "(REPLACE(REPLACE(REPLACE(seller_phone, ' ', ''), '+', ''), '-', '') LIKE ?)";
                    $params[] = '%' . $sellerPhoneClean . '%';
                } elseif (isset($_GET['seller_phone'])) {
                    sendResponse([
                        'success' => true,
                        'count' => 0,
                        'activities' => [],
                        'stats' => ['total_activities' => 0]
                    ]);
                    break;
                }

                if (!empty($sellerId)) {
                    $where[] = "seller_id = ?";
                    $params[] = $sellerId;
                }

                $userPhoneClean = !empty($userPhone) ? preg_replace('/[^0-9]/', '', $userPhone) : '';
                if (!empty($userPhoneClean) && !empty($userEmail)) {
                    $where[] = "((REPLACE(REPLACE(REPLACE(user_phone, ' ', ''), '+', ''), '-', '') LIKE ?) OR user_email = ?)";
                    $params[] = '%' . $userPhoneClean . '%';
                    $params[] = $userEmail;
                } elseif (!empty($userPhoneClean)) {
                    $where[] = "(REPLACE(REPLACE(REPLACE(user_phone, ' ', ''), '+', ''), '-', '') LIKE ?)";
                    $params[] = '%' . $userPhoneClean . '%';
                } elseif (!empty($userEmail)) {
                    $where[] = "user_email = ?";
                    $params[] = $userEmail;
                } elseif (isset($_GET['user_phone']) || isset($_GET['user_email'])) {
                    sendResponse([
                        'success' => true,
                        'count' => 0,
                        'activities' => [],
                        'stats' => ['total_activities' => 0]
                    ]);
                    break;
                }

                if (!empty($userId)) {
                    $where[] = "user_id = ?";
                    $params[] = $userId;
                }

                if (!empty($singleUser)) {
                    $cleanSingle = preg_replace('/[^0-9]/', '', $singleUser);
                    $where[] = "(user_name LIKE ? OR user_email LIKE ? OR REPLACE(REPLACE(REPLACE(user_phone, ' ', ''), '+', ''), '-', '') LIKE ?)";
                    $params[] = '%' . $singleUser . '%';
                    $params[] = '%' . $singleUser . '%';
                    $params[] = '%' . $cleanSingle . '%';
                }

                if (!empty($actionType) && $actionType !== 'all') {
                    $where[] = "action_type = ?";
                    $params[] = $actionType;
                }

                if (!empty($search)) {
                    $cleanSearch = preg_replace('/[^0-9]/', '', $search);
                    $where[] = "(user_name LIKE ? OR user_phone LIKE ? OR user_email LIKE ? OR property_title LIKE ? OR seller_name LIKE ? OR seller_phone LIKE ? OR property_location LIKE ?)";
                    $searchParam = '%' . $search . '%';
                    $params[] = $searchParam;
                    $params[] = '%' . $cleanSearch . '%';
                    $params[] = $searchParam;
                    $params[] = $searchParam;
                    $params[] = $searchParam;
                    $params[] = '%' . $cleanSearch . '%';
                    $params[] = $searchParam;
                }

                $whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
                $sql = "SELECT * FROM `user_activities` $whereSql ORDER BY `created_at` DESC LIMIT " . (int)$limit;
                
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $activities = $stmt->fetchAll(PDO::FETCH_ASSOC);

            } catch (Exception $e) {
                // Fallback to JSON if table or DB error
                $activities = getJsonActivities($activitiesFile);
            }
        } else {
            $activities = getJsonActivities($activitiesFile);
        }

        // Apply filters in memory if fallback was used
        if (!$pdo || empty($activities)) {
            $rawList = getJsonActivities($activitiesFile);
            if (!empty($rawList)) {
                $activities = array_filter($rawList, function($item) use ($sellerPhone, $userPhone, $singleUser, $actionType, $search) {
                    if (!empty($sellerPhone)) {
                        $cleanP1 = preg_replace('/[^0-9]/', '', $sellerPhone);
                        $cleanP2 = preg_replace('/[^0-9]/', '', $item['seller_phone'] ?? $item['sellerPhone'] ?? '');
                        if (strpos($cleanP2, $cleanP1) === false) return false;
                    }
                    if (!empty($userPhone)) {
                        $cleanU1 = preg_replace('/[^0-9]/', '', $userPhone);
                        $cleanU2 = preg_replace('/[^0-9]/', '', $item['user_phone'] ?? $item['userPhone'] ?? '');
                        if (strpos($cleanU2, $cleanU1) === false) return false;
                    }
                    if (!empty($actionType) && $actionType !== 'all') {
                        $act = $item['action_type'] ?? $item['actionType'] ?? '';
                        if ($act !== $actionType) return false;
                    }
                    if (!empty($search)) {
                        $s = strtolower($search);
                        $blob = strtolower(json_encode($item, JSON_UNESCAPED_UNICODE));
                        if (strpos($blob, $s) === false) return false;
                    }
                    return true;
                });
                $activities = array_values($activities);
            }
        }

        // Calculate detailed statistics for Super Admin
        $allActivities = getJsonActivities($activitiesFile);
        if ($pdo) {
            try {
                $countStmt = $pdo->query("SELECT * FROM `user_activities` ORDER BY `created_at` DESC");
                $allActivities = $countStmt->fetchAll(PDO::FETCH_ASSOC);
            } catch (Exception $e) {}
        }

        $totalActs = count($allActivities);
        $totalUnlocks = 0;
        $freeUnlocks = 0;
        $paidUnlocks = 0;
        $totalRevenue = 0.0;
        $userMap = [];
        $sellerMap = [];

        foreach ($allActivities as $act) {
            $type = $act['action_type'] ?? $act['actionType'] ?? '';
            $amt = (float)($act['amount'] ?? 0);

            if ($type === 'contact_unlock_paid') {
                $paidUnlocks++;
                $totalUnlocks++;
                $totalRevenue += $amt;
            } elseif ($type === 'contact_unlock_free' || $type === 'contact_view_free') {
                $freeUnlocks++;
                $totalUnlocks++;
            }

            $uPhone = trim($act['user_phone'] ?? $act['userPhone'] ?? '');
            $uName = trim($act['user_name'] ?? $act['userName'] ?? 'Customer');
            $uEmail = trim($act['user_email'] ?? $act['userEmail'] ?? '');
            $userKey = !empty($uPhone) ? $uPhone : (!empty($uEmail) ? $uEmail : $uName);

            if (!empty($userKey) && $userKey !== 'Customer') {
                if (!isset($userMap[$userKey])) {
                    $userMap[$userKey] = [
                        'key' => $userKey,
                        'name' => $uName,
                        'phone' => $uPhone,
                        'email' => $uEmail,
                        'totalActivities' => 0,
                        'unlocksCount' => 0,
                        'lastSeen' => $act['created_at'] ?? $act['createdAt'] ?? ''
                    ];
                }
                $userMap[$userKey]['totalActivities']++;
                if (strpos($type, 'contact') !== false) {
                    $userMap[$userKey]['unlocksCount']++;
                }
            }

            $sPhone = trim($act['seller_phone'] ?? $act['sellerPhone'] ?? '');
            if (!empty($sPhone)) {
                $sellerMap[$sPhone] = true;
            }
        }

        // Build property-level views and seller analytics
        $propViewsMap = [];
        $propUnlocksMap = [];

        foreach ($allActivities as $act) {
            $type = $act['action_type'] ?? $act['actionType'] ?? '';
            $pId = trim($act['property_id'] ?? $act['propertyId'] ?? '');
            $uName = trim($act['user_name'] ?? $act['userName'] ?? 'Customer');
            $uPhone = trim($act['user_phone'] ?? $act['userPhone'] ?? '');
            $uEmail = trim($act['user_email'] ?? $act['userEmail'] ?? '');
            $time = $act['created_at'] ?? $act['createdAt'] ?? '';

            if (!empty($pId)) {
                if (!isset($propViewsMap[$pId])) {
                    $propViewsMap[$pId] = [
                        'property_id' => $pId,
                        'property_title' => $act['property_title'] ?? $act['propertyTitle'] ?? '',
                        'seller_name' => $act['seller_name'] ?? $act['sellerName'] ?? '',
                        'seller_phone' => $act['seller_phone'] ?? $act['sellerPhone'] ?? '',
                        'views_count' => 0,
                        'viewers' => []
                    ];
                }
                if (!isset($propUnlocksMap[$pId])) {
                    $propUnlocksMap[$pId] = [
                        'unlocks_count' => 0,
                        'unlocks' => []
                    ];
                }

                if ($type === 'property_view') {
                    $propViewsMap[$pId]['views_count']++;
                    $propViewsMap[$pId]['viewers'][] = [
                        'user_name' => $uName,
                        'user_phone' => $uPhone,
                        'user_email' => $uEmail,
                        'viewed_at' => $time
                    ];
                } elseif (strpos($type, 'contact') !== false) {
                    $propUnlocksMap[$pId]['unlocks_count']++;
                    $propUnlocksMap[$pId]['unlocks'][] = [
                        'user_name' => $uName,
                        'user_phone' => $uPhone,
                        'user_email' => $uEmail,
                        'action_type' => $type,
                        'unlocked_at' => $time
                    ];
                }
            }
        }

        // Fetch properties to correlate sellers and posted ads
        $propsFile = DATA_DIR . '/properties.json';
        $allProps = [];
        if (file_exists($propsFile)) {
            $rawP = file_get_contents($propsFile);
            $decP = json_decode($rawP, true);
            if (is_array($decP)) $allProps = $decP;
        }
        if ($pdo) {
            try {
                $pStmt = $pdo->query("SELECT id, title, price, propertyType, status, sellerName, sellerPhone, contactPhone, postedDate FROM `properties`");
                $dbProps = $pStmt->fetchAll(PDO::FETCH_ASSOC);
                if (!empty($dbProps)) $allProps = $dbProps;
            } catch (Exception $e) {}
        }

        $postersMap = [];
        foreach ($allProps as $p) {
            $sPhone = trim($p['sellerPhone'] ?? $p['contactPhone'] ?? $p['seller_phone'] ?? '');
            $sName = trim($p['sellerName'] ?? $p['seller_name'] ?? 'Direct Owner');
            if (empty($sPhone)) continue;

            $sKey = preg_replace('/[^0-9]/', '', $sPhone);
            if (!isset($postersMap[$sKey])) {
                $postersMap[$sKey] = [
                    'seller_name' => $sName,
                    'seller_phone' => $sPhone,
                    'total_properties' => 0,
                    'total_views_received' => 0,
                    'total_unlocks_received' => 0,
                    'properties' => []
                ];
            }

            $pId = (string)($p['id'] ?? '');
            $pViews = $propViewsMap[$pId]['views_count'] ?? 0;
            $pUnlocks = $propUnlocksMap[$pId]['unlocks_count'] ?? 0;

            $postersMap[$sKey]['total_properties']++;
            $postersMap[$sKey]['total_views_received'] += $pViews;
            $postersMap[$sKey]['total_unlocks_received'] += $pUnlocks;
            $postersMap[$sKey]['properties'][] = [
                'id' => $pId,
                'title' => $p['title'] ?? '',
                'price' => (float)($p['price'] ?? 0),
                'propertyType' => $p['propertyType'] ?? $p['property_type'] ?? 'Land',
                'status' => $p['status'] ?? 'active',
                'views_count' => $pViews,
                'unlocks_count' => $pUnlocks,
                'viewers' => $propViewsMap[$pId]['viewers'] ?? []
            ];
        }

        usort($postersMap, function($a, $b) {
            return $b['total_views_received'] <=> $a['total_views_received'];
        });

        sendResponse([
            'success' => true,
            'total' => count($activities),
            'activities' => $activities,
            'stats' => [
                'totalActivities' => $totalActs,
                'totalContactUnlocks' => $totalUnlocks,
                'freeUnlocksCount' => $freeUnlocks,
                'paidUnlocksCount' => $paidUnlocks,
                'totalRevenue' => $totalRevenue,
                'uniqueUsersCount' => count($userMap),
                'uniqueSellersCount' => count($postersMap)
            ],
            'users' => array_values($userMap),
            'posters' => array_values($postersMap),
            'property_views' => array_values($propViewsMap)
        ]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        
        $userName = trim($input['userName'] ?? $input['user_name'] ?? 'Customer');
        $userPhone = trim($input['userPhone'] ?? $input['user_phone'] ?? '');
        $userEmail = trim($input['userEmail'] ?? $input['user_email'] ?? '');
        $userId = trim($input['userId'] ?? $input['user_id'] ?? ('user_' . rand(1000, 9999)));
        
        $actionType = trim($input['actionType'] ?? $input['action_type'] ?? 'property_view');
        $actionTitle = trim($input['actionTitle'] ?? $input['action_title'] ?? '');
        
        if (empty($actionTitle)) {
            if ($actionType === 'contact_unlock_free' || $actionType === 'contact_view_free') {
                $actionTitle = 'இலவச தொடர்பு எண் பார்வை (Free Unlock)';
            } elseif ($actionType === 'contact_unlock_paid') {
                $actionTitle = 'கட்டண தொடர்பு எண் திறப்பு (Paid Unlock)';
            } elseif ($actionType === 'property_post') {
                $actionTitle = 'புதிய விளம்பரம் பதிவு செய்யப்பட்டது (Post Ad)';
            } else {
                $actionTitle = 'சொத்து விவரம் பார்வை (Property View)';
            }
        }

        $propId = trim($input['propId'] ?? $input['property_id'] ?? '');
        $propTitle = trim($input['propTitle'] ?? $input['property_title'] ?? '');
        $propType = trim($input['propType'] ?? $input['property_type'] ?? 'Land');
        $propLocation = trim($input['propLocation'] ?? $input['property_location'] ?? 'Tenkasi');
        
        $sellerId = trim($input['sellerId'] ?? $input['seller_id'] ?? '');
        $sellerName = trim($input['sellerName'] ?? $input['seller_name'] ?? 'Direct Owner');
        $sellerPhone = trim($input['sellerPhone'] ?? $input['seller_phone'] ?? '');
        
        $amount = (float)($input['amount'] ?? 0.00);
        $details = is_array($input['details'] ?? null) ? json_encode($input['details'], JSON_UNESCAPED_UNICODE) : trim($input['details'] ?? '');

        $activityId = 'act_' . time() . '_' . rand(100, 999);
        $createdAt = date('Y-m-d H:i:s');

        $record = [
            'id' => $activityId,
            'user_id' => $userId,
            'user_name' => $userName,
            'user_phone' => $userPhone,
            'user_email' => $userEmail,
            'action_type' => $actionType,
            'action_title' => $actionTitle,
            'property_id' => $propId,
            'property_title' => $propTitle,
            'property_type' => $propType,
            'property_location' => $propLocation,
            'seller_id' => $sellerId,
            'seller_name' => $sellerName,
            'seller_phone' => $sellerPhone,
            'amount' => $amount,
            'details' => $details,
            'created_at' => $createdAt
        ];

        // 1. Save into MySQL if available
        $pdo = getDbConnection();
        $dbSaved = false;
        if ($pdo) {
            try {
                $stmt = $pdo->prepare("INSERT INTO `user_activities` 
                    (`id`, `user_id`, `user_name`, `user_phone`, `user_email`, `action_type`, `action_title`, `property_id`, `property_title`, `property_type`, `property_location`, `seller_id`, `seller_name`, `seller_phone`, `amount`, `details`, `created_at`) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->execute([
                    $activityId,
                    $userId,
                    $userName,
                    $userPhone,
                    $userEmail,
                    $actionType,
                    $actionTitle,
                    $propId,
                    $propTitle,
                    $propType,
                    $propLocation,
                    $sellerId,
                    $sellerName,
                    $sellerPhone,
                    $amount,
                    $details,
                    $createdAt
                ]);
                $dbSaved = true;
            } catch (Exception $e) {
                error_log('Activities DB insert error: ' . $e->getMessage());
            }
        }

        // 2. Also persist in JSON storage
        $jsonActivities = getJsonActivities($activitiesFile);
        array_unshift($jsonActivities, $record);
        if (count($jsonActivities) > 2000) {
            $jsonActivities = array_slice($jsonActivities, 0, 2000);
        }
        saveJsonActivities($activitiesFile, $jsonActivities);

        sendResponse([
            'success' => true,
            'message' => 'செயல்பாடு வெற்றிகரமாக பதிவு செய்யப்பட்டது (Activity logged)',
            'activity' => $record,
            'db_saved' => $dbSaved
        ]);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
        break;
}
