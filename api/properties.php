<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/events.php';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// Helper to get all properties - DB first, JSON fallback
function getPropertiesData() {
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->query("SELECT * FROM `properties` ORDER BY `postedDate` DESC, `created_at` DESC");
            $rows = $stmt->fetchAll();
            if ($rows !== false) {
                $properties = [];
                foreach ($rows as $r) {
                    $rawImageUrls = json_decode($r['imageUrls'] ?? '[]', true);
                    if (!is_array($rawImageUrls)) {
                        if (!empty($r['imageUrls']) && (str_starts_with($r['imageUrls'], '/9j/') || str_starts_with($r['imageUrls'], 'data:image/') || strlen($r['imageUrls']) > 500)) {
                            $uploadDir = __DIR__ . '/uploads/props';
                            if (!file_exists($uploadDir)) @mkdir($uploadDir, 0777, true);
                            $cleanBase64 = preg_replace('/^data:image\/[a-zA-Z0-9+]+;base64,/', '', $r['imageUrls']);
                            $decoded = base64_decode($cleanBase64);
                            $filename = 'prop_' . preg_replace('/[^a-zA-Z0-9_-]/', '', $r['id'] ?? 'unknown') . '_img.jpg';
                            @file_put_contents($uploadDir . '/' . $filename, $decoded);
                            $serverHost = $_SERVER['HTTP_HOST'] ?? 'ads.mithradigitalsolutions.com';
                            $publicUrl = 'https://' . $serverHost . '/api/uploads/props/' . $filename;
                            $rawImageUrls = [$publicUrl];
                            try {
                                $pdo->exec("UPDATE `properties` SET `imageUrls` = " . $pdo->quote(json_encode([$publicUrl])) . " WHERE `id` = " . $pdo->quote($r['id']));
                            } catch (Exception $e) {}
                        } else {
                            $rawImageUrls = [];
                        }
                    } else {
                        // Check if any element in array is raw base64
                        $updatedArray = [];
                        $hasBase64 = false;
                        foreach ($rawImageUrls as $idx => $u) {
                            if (is_string($u) && (str_starts_with($u, '/9j/') || str_starts_with($u, 'data:image/') || strlen($u) > 500)) {
                                $uploadDir = __DIR__ . '/uploads/props';
                                if (!file_exists($uploadDir)) @mkdir($uploadDir, 0777, true);
                                $cleanBase64 = preg_replace('/^data:image\/[a-zA-Z0-9+]+;base64,/', '', $u);
                                $decoded = base64_decode($cleanBase64);
                                $filename = 'prop_' . preg_replace('/[^a-zA-Z0-9_-]/', '', $r['id'] ?? 'unknown') . '_' . $idx . '.jpg';
                                @file_put_contents($uploadDir . '/' . $filename, $decoded);
                                $serverHost = $_SERVER['HTTP_HOST'] ?? 'ads.mithradigitalsolutions.com';
                                $publicUrl = 'https://' . $serverHost . '/api/uploads/props/' . $filename;
                                $updatedArray[] = $publicUrl;
                                $hasBase64 = true;
                            } else {
                                $updatedArray[] = $u;
                            }
                        }
                        if ($hasBase64) {
                            $rawImageUrls = $updatedArray;
                            try {
                                $pdo->exec("UPDATE `properties` SET `imageUrls` = " . $pdo->quote(json_encode($rawImageUrls)) . " WHERE `id` = " . $pdo->quote($r['id']));
                            } catch (Exception $e) {}
                        }
                    }

                    $firstImageUrl = count($rawImageUrls) > 0 ? $rawImageUrls[0] : null;

                    $prop = [
                        'id' => $r['id'],
                        'title' => $r['title'] ?? '',
                        'description' => $r['description'] ?? '',
                        'price' => (float)($r['price'] ?? 0),
                        'location' => $r['location'] ?? 'Tenkasi',
                        'city' => $r['city'] ?? 'Tenkasi',
                        'propertyType' => $r['propertyType'] ?? 'Land',
                        'areaSqFt' => (int)($r['areaSqFt'] ?? 0),
                        'superBuiltUpSqFt' => isset($r['superBuiltUpSqFt']) ? (int)$r['superBuiltUpSqFt'] : null,
                        'carpetAreaSqFt' => isset($r['carpetAreaSqFt']) ? (int)$r['carpetAreaSqFt'] : null,
                        'bedrooms' => isset($r['bedrooms']) && $r['bedrooms'] !== '' ? (int)$r['bedrooms'] : null,
                        'bathrooms' => isset($r['bathrooms']) && $r['bathrooms'] !== '' ? (int)$r['bathrooms'] : null,
                        'furnishingStatus' => $r['furnishingStatus'] ?? 'Unfurnished',
                        'facing' => $r['facing'] ?? 'East',
                        'floor' => $r['floor'] ?? 'Ground Floor',
                        'maintenanceMonthly' => isset($r['maintenanceMonthly']) ? (float)$r['maintenanceMonthly'] : null,
                        'landmark' => $r['landmark'] ?? '',
                        'posterType' => $r['posterType'] ?? 'Direct Owner',
                        'landUnit' => $r['landUnit'] ?? null,
                        'landUnitValue' => isset($r['landUnitValue']) ? (float)$r['landUnitValue'] : null,
                        'landFeatures' => json_decode($r['landFeatures'] ?? '[]', true) ?: [],
                        'approvalType' => $r['approvalType'] ?? null,
                        'isBankLoanAvailable' => (bool)($r['isBankLoanAvailable'] ?? false),
                        'isPriceNegotiable' => (bool)($r['isPriceNegotiable'] ?? true),
                        'waterSource' => $r['waterSource'] ?? 'Both',
                        'hasLift' => (bool)($r['hasLift'] ?? false),
                        'hasTrees' => (bool)($r['hasTrees'] ?? false),
                        'treesDetails' => $r['treesDetails'] ?? '',
                        'hasIncome' => (bool)($r['hasIncome'] ?? false),
                        'incomeDetails' => $r['incomeDetails'] ?? '',
                        'isLease' => (bool)($r['isLease'] ?? false),
                        'rentalSubType' => $r['rentalSubType'] ?? '',
                        'advanceAmount' => isset($r['advanceAmount']) ? (float)$r['advanceAmount'] : null,
                        'commercialAreaType' => $r['commercialAreaType'] ?? '',
                        'hasTable' => (bool)($r['hasTable'] ?? false),
                        'hasFan' => (bool)($r['hasFan'] ?? false),
                        'hasWaterSupply' => (bool)($r['hasWaterSupply'] ?? false),
                        'hasShutter' => (bool)($r['hasShutter'] ?? false),
                        'powerPhase' => $r['powerPhase'] ?? 'Single Phase',
                        'contactPhone' => $r['contactPhone'] ?? '+91 98941 74944',
                        'sellerName' => $r['sellerName'] ?? 'Direct Owner',
                        'sellerPhone' => $r['sellerPhone'] ?? '+91 98941 74944',
                        'imageKeys' => json_decode($r['imageKeys'] ?? '[]', true) ?: [],
                        'imageUrls' => $rawImageUrls,
                        'imageUrl' => $firstImageUrl,
                        'customImageBase64' => (!empty($_GET['id'])) ? ($r['customImageBase64'] ?? null) : null,
                        'amenities' => json_decode($r['amenities'] ?? '[]', true) ?: [],
                        'agent' => [
                            'id' => $r['agent_id'] ?? 'admin_agent',
                            'name' => $r['agent_name'] ?? $r['sellerName'] ?? 'Direct Owner',
                            'agencyName' => $r['agent_agencyName'] ?? 'நேரடி உரிமையாளர் (Direct Owner)',
                            'phone' => $r['agent_phone'] ?? $r['sellerPhone'] ?? '+91 98941 74944',
                            'email' => $r['agent_email'] ?? 'tenkasidreams@gmail.com'
                        ],
                        'postedDate' => $r['postedDate'] ?? $r['created_at'] ?? date('c'),
                        'status' => $r['status'] ?? 'active',
                        'isFavorite' => (bool)($r['isFavorite'] ?? false),
                        'isVerified' => (bool)($r['isVerified'] ?? true),
                        'isFeatured' => (bool)($r['isFeatured'] ?? false),
                        'isPremium' => (bool)($r['isPremium'] ?? false),
                        'isUserPosted' => (bool)($r['isUserPosted'] ?? false),
                        'views' => (int)($r['views'] ?? 0),
                        'enquiries' => (int)($r['enquiries'] ?? 0)
                    ];
                    $properties[] = $prop;
                }
                return $properties;
            }
        } catch (Exception $e) {
            // DB table query failed, fallback to json storage
        }
    }
    return readJsonStorage('properties.json');
}

// Helper to save property to DB + JSON
function savePropertyToDb($prop) {
    $pdo = getDbConnection();
    if (!$pdo) return false;

    try {
        $agent = $prop['agent'] ?? [];
        $sql = "INSERT INTO `properties` 
            (`id`, `title`, `description`, `price`, `location`, `city`, `propertyType`, `areaSqFt`, `superBuiltUpSqFt`, `carpetAreaSqFt`, `bedrooms`, `bathrooms`, `furnishingStatus`, `facing`, `floor`, `maintenanceMonthly`, `landmark`, `posterType`, `landUnit`, `landUnitValue`, `landFeatures`, `approvalType`, `isBankLoanAvailable`, `isPriceNegotiable`, `waterSource`, `hasLift`, `hasTrees`, `treesDetails`, `hasIncome`, `incomeDetails`, `isLease`, `rentalSubType`, `advanceAmount`, `commercialAreaType`, `hasTable`, `hasFan`, `hasWaterSupply`, `hasShutter`, `powerPhase`, `contactPhone`, `sellerName`, `sellerPhone`, `imageKeys`, `imageUrls`, `amenities`, `agent_id`, `agent_name`, `agent_agencyName`, `agent_phone`, `agent_email`, `postedDate`, `status`, `isFavorite`, `isVerified`, `isFeatured`, `isUserPosted`, `isPremium`, `views`, `enquiries`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE 
                `title`=VALUES(`title`), `description`=VALUES(`description`), `price`=VALUES(`price`),
                `location`=VALUES(`location`), `status`=VALUES(`status`), `isVerified`=VALUES(`isVerified`),
                `isFeatured`=VALUES(`isFeatured`), `isPremium`=VALUES(`isPremium`), `views`=VALUES(`views`), `enquiries`=VALUES(`enquiries`)";
        
        $stmt = $pdo->prepare($sql);
        return $stmt->execute([
            $prop['id'],
            $prop['title'] ?? '',
            $prop['description'] ?? '',
            $prop['price'] ?? 0,
            $prop['location'] ?? 'Tenkasi',
            $prop['city'] ?? 'Tenkasi',
            $prop['propertyType'] ?? 'Land',
            $prop['areaSqFt'] ?? 0,
            $prop['superBuiltUpSqFt'] ?? null,
            $prop['carpetAreaSqFt'] ?? null,
            $prop['bedrooms'] ?? null,
            $prop['bathrooms'] ?? null,
            $prop['furnishingStatus'] ?? 'Unfurnished',
            $prop['facing'] ?? 'East',
            $prop['floor'] ?? 'Ground Floor',
            $prop['maintenanceMonthly'] ?? null,
            $prop['landmark'] ?? null,
            $prop['posterType'] ?? 'Direct Owner',
            $prop['landUnit'] ?? null,
            $prop['landUnitValue'] ?? null,
            json_encode($prop['landFeatures'] ?? [], JSON_UNESCAPED_UNICODE),
            $prop['approvalType'] ?? null,
            !empty($prop['isBankLoanAvailable']) ? 1 : 0,
            isset($prop['isPriceNegotiable']) ? ($prop['isPriceNegotiable'] ? 1 : 0) : 1,
            $prop['waterSource'] ?? 'Both',
            !empty($prop['hasLift']) ? 1 : 0,
            !empty($prop['hasTrees']) ? 1 : 0,
            $prop['treesDetails'] ?? null,
            !empty($prop['hasIncome']) ? 1 : 0,
            $prop['incomeDetails'] ?? null,
            !empty($prop['isLease']) ? 1 : 0,
            $prop['rentalSubType'] ?? null,
            $prop['advanceAmount'] ?? null,
            $prop['commercialAreaType'] ?? null,
            !empty($prop['hasTable']) ? 1 : 0,
            !empty($prop['hasFan']) ? 1 : 0,
            !empty($prop['hasWaterSupply']) ? 1 : 0,
            !empty($prop['hasShutter']) ? 1 : 0,
            $prop['powerPhase'] ?? null,
            $prop['contactPhone'] ?? '',
            $prop['sellerName'] ?? 'Direct Owner',
            $prop['sellerPhone'] ?? '',
            json_encode($prop['imageKeys'] ?? [], JSON_UNESCAPED_UNICODE),
            json_encode($prop['imageUrls'] ?? [], JSON_UNESCAPED_UNICODE),
            json_encode($prop['amenities'] ?? [], JSON_UNESCAPED_UNICODE),
            $agent['id'] ?? 'admin_agent',
            $agent['name'] ?? $prop['sellerName'] ?? 'Direct Owner',
            $agent['agencyName'] ?? 'நேரடி உரிமையாளர் (Direct Owner)',
            $agent['phone'] ?? $prop['sellerPhone'] ?? '',
            $agent['email'] ?? $prop['sellerEmail'] ?? 'user@tenkasidreams.com',
            $prop['postedDate'] ?? date('Y-m-d H:i:s'),
            $prop['status'] ?? 'active',
            !empty($prop['isFavorite']) ? 1 : 0,
            isset($prop['isVerified']) ? ($prop['isVerified'] ? 1 : 0) : 1,
            !empty($prop['isFeatured']) ? 1 : 0,
            !empty($prop['isUserPosted']) ? 1 : 0,
            !empty($prop['isPremium']) ? 1 : 0,
            $prop['views'] ?? 0,
            $prop['enquiries'] ?? 0
        ]);
    } catch (Exception $e) {
        return false;
    }
}

// Helper to update property in DB
function updatePropertyInDb($id, $updates) {
    $pdo = getDbConnection();
    if (!$pdo) return false;

    try {
        $sets = [];
        $params = [];
        foreach ($updates as $k => $v) {
            if ($k === 'id' || $k === 'agent') continue;
            if (in_array($k, ['landFeatures', 'imageKeys', 'imageUrls', 'amenities'])) {
                $sets[] = "`$k` = ?";
                $params[] = json_encode($v, JSON_UNESCAPED_UNICODE);
            } elseif (is_bool($v)) {
                $sets[] = "`$k` = ?";
                $params[] = $v ? 1 : 0;
            } else {
                $sets[] = "`$k` = ?";
                $params[] = $v;
            }
        }
        if (empty($sets)) return false;
        $params[] = $id;
        $sql = "UPDATE `properties` SET " . implode(', ', $sets) . " WHERE `id` = ?";
        $stmt = $pdo->prepare($sql);
        return $stmt->execute($params);
    } catch (Exception $e) {
        return false;
    }
}

// Helper to delete property from DB
function deletePropertyFromDb($id) {
    $pdo = getDbConnection();
    if (!$pdo) return false;
    try {
        $stmt = $pdo->prepare("DELETE FROM `properties` WHERE `id` = ?");
        $stmt->execute([$id]);
        return $stmt->rowCount() > 0;
    } catch (Exception $e) {
        return false;
    }
}

// Helper to save all properties (JSON fallback + sync)
function savePropertiesData($properties) {
    writeJsonStorage('properties.json', $properties);
}

// Helper to update notifications file
function syncNotificationStatus($propertyId, $newStatus) {
    // Update JSON
    $notifsFile = DATA_DIR . '/notifications.json';
    if (file_exists($notifsFile)) {
        $notifs = json_decode(file_get_contents($notifsFile), true);
        if (is_array($notifs)) {
            $updated = false;
            foreach ($notifs as &$n) {
                if (($n['propertyId'] ?? '') == $propertyId) {
                    $n['status'] = $newStatus;
                    $n['isRead'] = true;
                    $updated = true;
                }
            }
            if ($updated) {
                file_put_contents($notifsFile, json_encode(array_values($notifs), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
            }
        }
    }
    // Update DB
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->prepare("UPDATE `notifications` SET `status` = ?, `isRead` = 1 WHERE `propertyId` = ?");
            $stmt->execute([$newStatus, $propertyId]);
}

// Automatically regenerates sitemap.xml on every product/property add, update, delete or approval
function triggerSitemapUpdate() {
    $sitemapFile = dirname(__DIR__) . '/sitemap.php';
    if (file_exists($sitemapFile)) {
        try {
            require_once $sitemapFile;
            if (function_exists('buildSitemapXml')) {
                buildSitemapXml(true);
            }
        } catch (Exception $e) {}
    }
}


// Helper to process and persist uploaded property image (Base64 -> File URL)
function processPropertyImage($input, $propertyId) {
    $rawList = is_array($input['imageUrls'] ?? null) ? $input['imageUrls'] : (!empty($input['imageUrl']) ? [$input['imageUrl']] : (!empty($input['images']) && is_array($input['images']) ? $input['images'] : []));
    $customBase64 = $input['customImageBase64'] ?? $input['imageBase64'] ?? null;
    if (!empty($customBase64) && !in_array($customBase64, $rawList)) {
        array_unshift($rawList, $customBase64);
    }

    $uploadDir = __DIR__ . '/uploads/props';
    if (!file_exists($uploadDir)) {
        @mkdir($uploadDir, 0777, true);
    }
    $serverHost = $_SERVER['HTTP_HOST'] ?? 'ads.mithradigitalsolutions.com';
    $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? 'https' : 'https';
    $cleanId = preg_replace('/[^a-zA-Z0-9_-]/', '', $propertyId);

    $finalUrls = [];
    $imgIndex = 0;

    foreach ($rawList as $item) {
        if (!is_string($item) || empty($item)) continue;

        if (str_starts_with($item, 'data:image/')) {
            try {
                $cleanBase64 = preg_replace('/^data:image\/[a-zA-Z0-9+]+;base64,/', '', $item);
                $decoded = base64_decode($cleanBase64);
                if ($decoded !== false && strlen($decoded) > 50) {
                    $imgIndex++;
                    $filename = 'prop_' . $cleanId . '_' . time() . '_' . $imgIndex . '.jpg';
                    $filePath = $uploadDir . '/' . $filename;
                    if (@file_put_contents($filePath, $decoded) !== false) {
                        $publicUrl = $protocol . '://' . $serverHost . '/api/uploads/props/' . $filename;
                        $finalUrls[] = $publicUrl;
                        continue;
                    }
                }
            } catch (Exception $e) {
                error_log('Image processing error: ' . $e->getMessage());
            }
        } else {
            // Already a URL or path
            $finalUrls[] = $item;
        }
    }

    $finalUrls = array_values(array_unique(array_filter($finalUrls)));
    return [
        'imageUrls' => $finalUrls,
        'imageUrl' => count($finalUrls) > 0 ? $finalUrls[0] : null,
        'customImageBase64' => count($finalUrls) > 0 ? $finalUrls[0] : null
    ];
}

switch ($method) {
    case 'GET':
        // Ultra-lightweight status check for Super Admin (1ms, ~50 bytes)
        if (isset($_GET['action']) && $_GET['action'] === 'pending_check') {
            $pdo = getDbConnection();
            $cnt = 0;
            $latestId = '';
            $latestTitle = '';
            if ($pdo) {
                try {
                    $stmt = $pdo->query("SELECT `id`, `title` FROM `properties` WHERE LOWER(`status`) = 'pending' ORDER BY `postedDate` DESC, `created_at` DESC LIMIT 1");
                    $row = $stmt->fetch(PDO::FETCH_ASSOC);
                    if ($row) {
                        $latestId = $row['id'] ?? '';
                        $latestTitle = $row['title'] ?? '';
                    }
                    $cntStmt = $pdo->query("SELECT COUNT(*) as cnt FROM `properties` WHERE LOWER(`status`) = 'pending'");
                    $cnt = (int)($cntStmt->fetch(PDO::FETCH_ASSOC)['cnt'] ?? 0);
                } catch (Exception $e) {}
            }
            sendResponse([
                'success' => true,
                'pending_count' => $cnt,
                'latest_pending_id' => $latestId,
                'latest_pending_title' => $latestTitle
            ]);
            exit();
        }

        $properties = getPropertiesData();
        
        // Single property lookup
        if (isset($_GET['id'])) {
            $id = $_GET['id'];
            foreach ($properties as $p) {
                if ($p['id'] == $id) {
                    sendResponse(['success' => true, 'property' => $p]);
                }
            }
            sendResponse(['success' => false, 'message' => 'விளம்பரம் கிடைக்கவில்லை (Property not found)'], 404);
        }

        // Search & Filter
        $filtered = $properties;

        // Category filter
        if (!empty($_GET['category']) && $_GET['category'] !== 'all') {
            $cat = strtolower($_GET['category']);
            $filtered = array_filter($filtered, function ($p) use ($cat) {
                $type = strtolower($p['propertyType'] ?? '');
                if ($cat === 'house' || $cat === 'villa') return str_contains($type, 'house') || str_contains($type, 'villa');
                if ($cat === 'land' || $cat === 'plot' || $cat === 'plots') return $type === 'land' || str_contains($type, 'land') || str_contains($type, 'plot');
                if ($cat === 'farmland' || $cat === 'thottam' || $cat === 'farm land') return str_contains($type, 'farm') || str_contains($type, 'thottam');
                if ($cat === 'shop' || $cat === 'commercial') return str_contains($type, 'shop') || str_contains($type, 'commercial') || str_contains($type, 'office');
                if ($cat === 'apartment' || $cat === 'flat') return str_contains($type, 'apartment') || str_contains($type, 'flat');
                if ($cat === 'rental' || $cat === 'lease') return ($p['isRental'] ?? false) || str_contains($type, 'rental') || str_contains($type, 'lease');
                return str_contains($type, $cat);
            });
        }

        // Filter by user_phone (for My Ads / Profile) - STRICT ISOLATION
        if (!empty($_GET['user_phone'])) {
            $rawPhone = preg_replace('/[^0-9]/', '', $_GET['user_phone']);
            if (strlen($rawPhone) >= 10) {
                $rawPhoneSuffix = substr($rawPhone, -10);
                $filtered = array_filter($filtered, function ($p) use ($rawPhoneSuffix) {
                    $cp = preg_replace('/[^0-9]/', '', $p['contactPhone'] ?? '');
                    $sp = preg_replace('/[^0-9]/', '', $p['sellerPhone'] ?? '');
                    $ap = preg_replace('/[^0-9]/', '', $p['agent']['phone'] ?? '');
                    return str_ends_with($cp, $rawPhoneSuffix) ||
                           str_ends_with($sp, $rawPhoneSuffix) ||
                           str_ends_with($ap, $rawPhoneSuffix);
                });
            } else {
                $filtered = [];
            }
        }

        // Filter by user_email (for Google Sign-In My Ads / Profile) - STRICT ISOLATION
        if (!empty($_GET['user_email'])) {
            $targetEmail = strtolower(trim($_GET['user_email']));
            $filtered = array_filter($filtered, function ($p) use ($targetEmail) {
                $agentEmail = strtolower(trim($p['agent']['email'] ?? ''));
                $sellerEmail = strtolower(trim($p['sellerEmail'] ?? ''));
                return ($agentEmail === $targetEmail) || ($sellerEmail === $targetEmail);
            });
        }

        // Status filter:
        // Public listing requests MUST ONLY see 'active' (approved) properties.
        // Non-active (pending, rejected) properties are ONLY returned if:
        // 1. A specific user_email or user_phone is provided (user viewing their own posts history in "My Posts"), OR
        // 2. An explicit status is requested (e.g. status=pending, status=rejected, status=all), OR
        // 3. Admin / full sync query is requested (all=true, admin=true).
        $isUserMyPostsQuery = !empty($_GET['user_phone']) || !empty($_GET['user_email']);
        $hasExplicitStatus  = !empty($_GET['status']);
        $isAllOrAdmin       = (isset($_GET['all']) && $_GET['all'] === 'true') ||
                              (isset($_GET['admin']) && $_GET['admin'] === 'true') ||
                              (isset($_GET['status']) && $_GET['status'] === 'all');

        if ($hasExplicitStatus && $_GET['status'] !== 'all') {
            $status = strtolower($_GET['status']);
            $filtered = array_filter($filtered, function ($p) use ($status) {
                return strtolower($p['status'] ?? 'active') === $status;
            });
        } elseif (!$isUserMyPostsQuery && !$isAllOrAdmin) {
            // STRICT SERVER-SIDE ENFORCEMENT: Public guest listings ONLY show 'active' (approved) properties!
            $filtered = array_filter($filtered, function ($p) {
                $st = strtolower($p['status'] ?? 'active');
                return $st === 'active';
            });
        }

        // Search query
        if (!empty($_GET['query']) || !empty($_GET['search'])) {
            $q = strtolower(trim($_GET['query'] ?? $_GET['search']));
            $filtered = array_filter($filtered, function ($p) use ($q) {
                return str_contains(strtolower($p['title'] ?? ''), $q) ||
                       str_contains(strtolower($p['location'] ?? ''), $q) ||
                       str_contains(strtolower($p['city'] ?? ''), $q) ||
                       str_contains(strtolower($p['description'] ?? ''), $q) ||
                       str_contains(strtolower($p['propertyType'] ?? ''), $q);
            });
        }

        $totalCount = count($filtered);
        $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 0;
        
        $pagedList = array_values($filtered);
        $totalPages = 1;
        
        if ($limit > 0) {
            $totalPages = max(1, (int)ceil($totalCount / $limit));
            $offset = ($page - 1) * $limit;
            $pagedList = array_slice($pagedList, $offset, $limit);
        }

        // Strictly strip customImageBase64 and convert base64 imageUrls to file URLs for all list responses
        if (empty($_GET['id'])) {
            $uploadDir = __DIR__ . '/uploads/props';
            if (!file_exists($uploadDir)) @mkdir($uploadDir, 0777, true);
            $serverHost = $_SERVER['HTTP_HOST'] ?? 'ads.mithradigitalsolutions.com';

            foreach ($pagedList as &$item) {
                unset($item['customImageBase64']);
                if (isset($item['imageUrls']) && is_array($item['imageUrls'])) {
                    foreach ($item['imageUrls'] as $k => $imgStr) {
                        if (is_string($imgStr) && strlen($imgStr) > 500) {
                            $cleanBase64 = preg_replace('/^data:image\/[a-zA-Z0-9+]+;base64,/', '', $imgStr);
                            $decoded = base64_decode($cleanBase64);
                            if ($decoded !== false && strlen($decoded) > 50) {
                                $filename = 'prop_' . preg_replace('/[^a-zA-Z0-9_-]/', '', $item['id'] ?? 'unknown') . '_' . $k . '.jpg';
                                @file_put_contents($uploadDir . '/' . $filename, $decoded);
                                $item['imageUrls'][$k] = 'https://' . $serverHost . '/api/uploads/props/' . $filename;
                            }
                        }
                    }
                    $item['imageUrl'] = count($item['imageUrls']) > 0 ? $item['imageUrls'][0] : null;
                }
            }
            unset($item);
        }

        sendResponse([
            'success' => true,
            'count' => count($pagedList),
            'total' => $totalCount,
            'page' => $page,
            'limit' => $limit,
            'total_pages' => $totalPages,
            'has_more' => ($limit > 0 && $page < $totalPages),
            'properties' => $pagedList,
            'data' => $pagedList
        ]);
        break;

    case 'POST':
        $action = $_GET['action'] ?? '';
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        if (empty($action) && isset($input['action'])) {
            $action = $input['action'];
        }

        // Handle Admin Quick Approval, Rejection & Update Status Actions
        if ($action === 'update_status' || $action === 'approve' || $action === 'reject') {
            $propId = $input['id'] ?? $_GET['id'] ?? null;
            if (!$propId) {
                sendResponse(['success' => false, 'message' => 'Property ID is required'], 400);
            }

            $newStatus = 'active';
            if ($action === 'approve') {
                $newStatus = 'active';
            } elseif ($action === 'reject') {
                $newStatus = 'rejected';
            } else {
                $newStatus = strtolower(trim($input['status'] ?? $_GET['status'] ?? 'active'));
            }

            $isVerified = ($newStatus === 'active');

            // Update in DB
            updatePropertyInDb($propId, ['status' => $newStatus, 'isVerified' => $isVerified]);

            // Update in JSON
            $properties = readJsonStorage('properties.json');
            $sellerPhone = '';
            foreach ($properties as &$p) {
                if ($p['id'] == $propId) {
                    $p['status'] = $newStatus;
                    $p['isVerified'] = $isVerified;
                    $sellerPhone = $p['sellerPhone'] ?? $p['contactPhone'] ?? '';
                    break;
                }
            }
            writeJsonStorage('properties.json', $properties);
            syncNotificationStatus($propId, $newStatus);
            triggerSitemapUpdate();

            // Emit real-time events to Super Admin and seller
            emitRealtimeEvent('admin', 'pending_ad_action_taken', [
                'propertyId' => $propId,
                'status' => $newStatus,
                'action' => $newStatus
            ]);
            if (!empty($sellerPhone)) {
                emitRealtimeEvent($sellerPhone, 'property_approval_status', [
                    'propertyId' => $propId,
                    'status' => $newStatus,
                    'message' => ($newStatus === 'active')
                        ? 'உங்கள் விளம்பரம் வெற்றிகரமாக அப்ரூவல் செய்யப்பட்டு நேரலை செய்யப்பட்டது!'
                        : 'உங்கள் விளம்பரம் நிராகரிக்கப்பட்டது.'
                ]);
            }

            sendResponse([
                'success' => true,
                'message' => ($newStatus === 'active')
                    ? 'விளம்பரம் வெற்றிகரமாக ஒப்புதல் (Approved) அளிக்கப்பட்டு நேரலை செய்யப்பட்டது!'
                    : 'விளம்பரம் நிராகரிக்கப்பட்டது (Property Rejected)!',
                'propertyId' => $propId,
                'status' => $newStatus
            ]);
            break;
        }

        // Handle Admin Toggle Premium / Free Action
        if ($action === 'toggle_premium') {
            $propId = $input['id'] ?? $_GET['id'] ?? null;
            if (!$propId) {
                sendResponse(['success' => false, 'message' => 'Property ID is required'], 400);
            }
            $isPremium = !empty($input['isPremium']);
            // Update in DB
            updatePropertyInDb($propId, ['isPremium' => $isPremium ? 1 : 0]);
            // Update in JSON
            $properties = readJsonStorage('properties.json');
            foreach ($properties as &$p) {
                if ($p['id'] == $propId) {
                    $p['isPremium'] = $isPremium;
                    break;
                }
            }
            writeJsonStorage('properties.json', $properties);

            sendResponse([
                'success' => true,
                'message' => $isPremium ? 'விளம்பரம் கட்டணம் (Paid / Premium) என மாற்றப்பட்டது!' : 'விளம்பரம் இலவசம் (Free) என மாற்றப்பட்டது!',
                'propertyId' => $propId,
                'isPremium' => $isPremium
            ]);
            break;
        }

        // Standard Property Creation (Public User or Admin)
        $fromAdmin = !empty($input['fromAdmin']) && ($input['fromAdmin'] === true || $input['fromAdmin'] === 'true' || $input['fromAdmin'] === 1 || $input['fromAdmin'] === '1');
        $isUserSubmission = !$fromAdmin;

        $agentInput = $input['agent'] ?? [];
        $sellerPhone = trim($input['sellerPhone'] ?? $input['agent_phone'] ?? $input['contactPhone'] ?? ($agentInput['phone'] ?? ''));
        $sellerEmail = trim($input['sellerEmail'] ?? $input['agent_email'] ?? $input['user_email'] ?? ($agentInput['email'] ?? ''));
        $sellerName = trim($input['sellerName'] ?? $input['agent_name'] ?? $input['agentName'] ?? ($agentInput['name'] ?? ($fromAdmin ? 'Super Admin' : 'Direct Owner')));
        $rawTitle = trim($input['title'] ?? '');
        $rawType = trim($input['propertyType'] ?? 'Land');

        if (empty($rawTitle)) {
            sendResponse(['success' => false, 'message' => 'விளம்பர தலைப்பு தேவை (Title is required)'], 400);
        }

        $newId = 'prop_' . (time()) . '_' . rand(100, 999);

        $status = $isUserSubmission ? 'pending' : trim($input['status'] ?? 'active');
        $isVerified = $isUserSubmission ? false : (isset($input['isVerified']) ? (bool)$input['isVerified'] : true);
        $isUserPosted = $isUserSubmission ? true : (bool)($input['isUserPosted'] ?? false);

        $posterType = trim($input['posterType'] ?? ($fromAdmin ? 'Super Admin' : 'Direct Owner'));
        $isOwner = (stripos($posterType, 'Owner') !== false);
        $isPremium = isset($input['isPremium']) ? (bool)$input['isPremium'] : ($isOwner ? true : false);

        // Process property image (Base64 -> Public File URL)
        $imgResult = processPropertyImage($input, $newId);
        $finalImageUrls = $imgResult['imageUrls'];
        $finalImageUrl = $imgResult['imageUrl'];
        $finalBase64 = $imgResult['customImageBase64'];

        $newProperty = [
            'id' => $newId,
            'title' => trim($input['title']),
            'description' => trim($input['description'] ?? ''),
            'price' => (float)($input['price'] ?? 0),
            'location' => trim($input['location'] ?? 'Tenkasi, Tamil Nadu'),
            'city' => trim($input['city'] ?? 'Tenkasi'),
            'propertyType' => trim($input['propertyType']),
            'areaSqFt' => (int)($input['areaSqFt'] ?? 0),
            'superBuiltUpSqFt' => (int)($input['superBuiltUpSqFt'] ?? $input['areaSqFt'] ?? 0),
            'carpetAreaSqFt' => (int)($input['carpetAreaSqFt'] ?? $input['areaSqFt'] ?? 0),
            'bedrooms' => isset($input['bedrooms']) && $input['bedrooms'] !== '' ? (int)$input['bedrooms'] : null,
            'bathrooms' => isset($input['bathrooms']) && $input['bathrooms'] !== '' ? (int)$input['bathrooms'] : null,
            'furnishingStatus' => trim($input['furnishingStatus'] ?? 'Unfurnished'),
            'facing' => trim($input['facing'] ?? 'East'),
            'floor' => trim($input['floor'] ?? 'Ground Floor'),
            'maintenanceMonthly' => isset($input['maintenanceMonthly']) ? (float)$input['maintenanceMonthly'] : null,
            'landmark' => trim($input['landmark'] ?? ''),
            'posterType' => $posterType,
            'landUnit' => trim($input['landUnit'] ?? 'Cent'),
            'landUnitValue' => isset($input['landUnitValue']) ? (float)$input['landUnitValue'] : null,
            'landFeatures' => is_array($input['landFeatures'] ?? null) ? $input['landFeatures'] : [],
            'approvalType' => trim($input['approvalType'] ?? 'DTCP Approved'),
            'isBankLoanAvailable' => (bool)($input['isBankLoanAvailable'] ?? false),
            'isPriceNegotiable' => (bool)($input['isPriceNegotiable'] ?? true),
            'waterSource' => trim($input['waterSource'] ?? 'Both'),
            'hasLift' => (bool)($input['hasLift'] ?? false),
            // Farmland
            'hasTrees' => (bool)($input['hasTrees'] ?? false),
            'treesDetails' => trim($input['treesDetails'] ?? ''),
            'hasIncome' => (bool)($input['hasIncome'] ?? false),
            'incomeDetails' => trim($input['incomeDetails'] ?? ''),
            // Rental & Commercial
            'isLease' => (bool)($input['isLease'] ?? false),
            'rentalSubType' => trim($input['rentalSubType'] ?? ''),
            'advanceAmount' => isset($input['advanceAmount']) ? (float)$input['advanceAmount'] : null,
            'commercialAreaType' => trim($input['commercialAreaType'] ?? ''),
            'hasTable' => (bool)($input['hasTable'] ?? false),
            'hasFan' => (bool)($input['hasFan'] ?? false),
            'hasWaterSupply' => (bool)($input['hasWaterSupply'] ?? false),
            'hasShutter' => (bool)($input['hasShutter'] ?? false),
            'powerPhase' => trim($input['powerPhase'] ?? 'Single Phase'),
            'contactPhone' => $sellerPhone,
            'sellerName' => $sellerName,
            'sellerPhone' => $sellerPhone,
            'sellerEmail' => $sellerEmail,
            'imageKeys' => is_array($input['imageKeys'] ?? null) && count($input['imageKeys']) > 0 ? $input['imageKeys'] : ['house_1'],
            'imageUrls' => $finalImageUrls,
            'imageUrl' => $finalImageUrl,
            'customImageBase64' => $finalBase64,
            'amenities' => is_array($input['amenities'] ?? null) ? $input['amenities'] : ['24x7 Security', 'Power Backup'],
            'agent' => [
                'id' => $isUserSubmission ? ('user_' . time()) : 'admin_agent',
                'name' => $sellerName,
                'agencyName' => $isUserSubmission ? 'நேரடி உரிமையாளர் (Direct Owner)' : 'Tenkasi Dreams Land',
                'phone' => $sellerPhone,
                'email' => !empty($sellerEmail) ? $sellerEmail : ($fromAdmin ? 'tenkasidreams@gmail.com' : 'user@tenkasidreams.com')
            ],
            'postedDate' => date('c'),
            'status' => $status,
            'isFavorite' => false,
            'isVerified' => $isVerified,
            'isFeatured' => isset($input['isFeatured']) ? (bool)$input['isFeatured'] : false,
            'isUserPosted' => $isUserPosted,
            'isPremium' => $isPremium,
            'views' => 1,
            'enquiries' => 0
        ];

        // Save to DB
        savePropertyToDb($newProperty);

        // Save to JSON (as backup)
        $properties = readJsonStorage('properties.json');
        array_unshift($properties, $newProperty);
        writeJsonStorage('properties.json', $properties);
        triggerSitemapUpdate();

        // If user submitted, automatically add a Super Admin Notification
        if ($isUserSubmission) {
            $formattedPrice = '₹' . number_format($newProperty['price']);
            $newNotif = [
                'id' => 'notif_' . time() . '_' . rand(100, 999),
                'type' => 'new_property_ad',
                'title' => '🔔 புதிய விளம்பரம் அப்ரூவலுக்கு வந்துள்ளது!',
                'message' => "{$sellerName} ({$sellerPhone}) என்பவர் '{$newProperty['title']}' ({$formattedPrice}) என்ற புதிய விளம்பரத்தை பதிவிட்டுள்ளார். சரிபார்த்து அப்ரூவல் வழங்கவும்.",
                'propertyId' => $newId,
                'propertyTitle' => $newProperty['title'],
                'sellerName' => $sellerName,
                'sellerPhone' => $sellerPhone,
                'price' => $newProperty['price'],
                'propertyType' => $newProperty['propertyType'],
                'location' => $newProperty['location'],
                'timestamp' => date('c'),
                'isRead' => false,
                'status' => 'pending'
            ];

            // Save notification to JSON
            $notifsFile = DATA_DIR . '/notifications.json';
            $notifs = file_exists($notifsFile) ? json_decode(file_get_contents($notifsFile), true) : [];
            if (!is_array($notifs)) $notifs = [];
            array_unshift($notifs, $newNotif);
            file_put_contents($notifsFile, json_encode(array_values($notifs), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

            // Save notification to DB
            $pdo = getDbConnection();
            if ($pdo) {
                try {
                    $nStmt = $pdo->prepare("INSERT INTO `notifications` (`id`, `type`, `title`, `message`, `propertyId`, `propertyTitle`, `sellerName`, `sellerPhone`, `price`, `propertyType`, `location`, `isRead`, `status`, `timestamp`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    $nStmt->execute([
                        $newNotif['id'], $newNotif['type'], $newNotif['title'], $newNotif['message'],
                        $newNotif['propertyId'], $newNotif['propertyTitle'], $newNotif['sellerName'],
                        $newNotif['sellerPhone'], $newNotif['price'], $newNotif['propertyType'],
                        $newNotif['location'], 0, 'pending', $newNotif['timestamp']
                    ]);
                } catch (Exception $e) {}
            }

            // Emit real-time event to Super Admin immediately!
            emitRealtimeEvent('admin', 'new_pending_ad', [
                'property' => $newProperty,
                'notification' => $newNotif,
                'timestamp' => date('c')
            ]);

            // Trigger high-priority FCM push notification with loud call/alarm ringtone to Super Admin!
            try {
                require_once __DIR__ . '/fcm_service.php';
                sendAdminNewAdNotification($newProperty);
            } catch (Exception $e) {
                error_log('FCM dispatch error: ' . $e->getMessage());
            }
        }

        $successMsg = $isUserSubmission 
            ? 'உங்கள் விளம்பரம் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது! சூப்பர் அட்மின் சரிபார்த்து அப்ரூவல் செய்தவுடன் தளத்தில் நேரலையாக தோன்றும்.'
            : 'புதிய விளம்பரம் வெற்றிகரமாக சேர்க்கப்பட்டது! (Property created successfully)';

        sendResponse([
            'success' => true,
            'message' => $successMsg,
            'property' => $newProperty,
            'isPendingApproval' => $isUserSubmission
        ], 201);
        break;

    case 'PUT':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $id = $input['id'] ?? $_GET['id'] ?? null;

        if (!$id) {
            sendResponse(['success' => false, 'message' => 'Property ID is required'], 400);
        }

        // Process images if updated
        if (!empty($input['customImageBase64']) || !empty($input['imageUrl']) || !empty($input['imageUrls'])) {
            $imgResult = processPropertyImage($input, $id);
            $input['imageUrls'] = $imgResult['imageUrls'];
            $input['imageUrl'] = $imgResult['imageUrl'];
        }

        // Update in DB
        updatePropertyInDb($id, $input);

        // Update in JSON (backup)
        $properties = readJsonStorage('properties.json');
        $foundIndex = -1;
        foreach ($properties as $idx => $p) {
            if ($p['id'] == $id) {
                $foundIndex = $idx;
                break;
            }
        }

        if ($foundIndex !== -1) {
            foreach ($input as $k => $v) {
                if ($k !== 'id') {
                    $properties[$foundIndex][$k] = $v;
                }
            }
            writeJsonStorage('properties.json', $properties);
        }

        // Sync notification if status changed
        if (isset($input['status'])) {
            syncNotificationStatus($id, $input['status'] === 'active' ? 'approved' : $input['status']);
        }
        triggerSitemapUpdate();

        $updatedProp = $foundIndex !== -1 ? $properties[$foundIndex] : $input;
        sendResponse([
            'success' => true,
            'message' => 'விளம்பரம் வெற்றிகரமாக திருத்தப்பட்டது! (Property updated successfully)',
            'property' => $updatedProp
        ]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) {
            $input = json_decode(file_get_contents('php://input'), true);
            $id = $input['id'] ?? null;
        }

        if (!$id) {
            sendResponse(['success' => false, 'message' => 'Property ID is required'], 400);
        }

        // Delete from DB
        $dbDeleted = deletePropertyFromDb($id);

        // Delete from JSON
        $properties = readJsonStorage('properties.json');
        $initialCount = count($properties);
        $properties = array_filter($properties, function ($p) use ($id) {
            return $p['id'] != $id;
        });
        $jsonDeleted = count($properties) !== $initialCount;

        if (!$dbDeleted && !$jsonDeleted) {
            sendResponse(['success' => false, 'message' => 'Property not found'], 404);
        }

        if ($jsonDeleted) {
            writeJsonStorage('properties.json', array_values($properties));
        }
        syncNotificationStatus($id, 'deleted');
        triggerSitemapUpdate();

        sendResponse([
            'success' => true,
            'message' => 'விளம்பரம் வெற்றிகரமாக நீக்கப்பட்டது! (Property deleted successfully)'
        ]);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}
