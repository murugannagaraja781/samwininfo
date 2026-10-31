<?php
require_once __DIR__ . '/config.php';

// Use DB-aware property loader
function getPropertiesForStats() {
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->query("SELECT `propertyType`, `status`, `isVerified`, `views`, `enquiries` FROM `properties`");
            $rows = $stmt->fetchAll();
            if ($rows !== false) return $rows;
        } catch (Exception $e) {}
    }
    return readJsonStorage('properties.json');
}

function getRequirementsForStats() {
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->query("SELECT `status` FROM `buyer_requirements`");
            $rows = $stmt->fetchAll();
            if ($rows !== false) return $rows;
        } catch (Exception $e) {}
    }
    return readJsonStorage('requirements.json');
}

$properties = getPropertiesForStats();
$requirements = getRequirementsForStats();

$total = count($properties);
$active = 0;
$pending = 0;
$sold = 0;
$verified = 0;
$totalViews = 0;
$totalEnquiries = 0;

$categories = [
    'House' => 0,
    'Land' => 0,
    'Farmland' => 0,
    'Shop' => 0,
    'Apartment' => 0,
    'Rental' => 0,
];

foreach ($properties as $p) {
    $status = strtolower($p['status'] ?? 'active');
    if ($status === 'active') $active++;
    elseif ($status === 'pending') $pending++;
    elseif ($status === 'sold') $sold++;

    if (!empty($p['isVerified'])) $verified++;

    $totalViews += (int)($p['views'] ?? 0);
    $totalEnquiries += (int)($p['enquiries'] ?? 0);

    $type = strtolower($p['propertyType'] ?? '');
    if (str_contains($type, 'farm') || str_contains($type, 'thottam')) {
        $categories['Farmland']++;
    } elseif (str_contains($type, 'house') || str_contains($type, 'villa')) {
        $categories['House']++;
    } elseif (str_contains($type, 'land') || str_contains($type, 'plot')) {
        $categories['Land']++;
    } elseif (str_contains($type, 'shop') || str_contains($type, 'commercial') || str_contains($type, 'office')) {
        $categories['Shop']++;
    } elseif (str_contains($type, 'apartment') || str_contains($type, 'flat')) {
        $categories['Apartment']++;
    } elseif (!empty($p['isRental']) || str_contains($type, 'rental') || str_contains($type, 'lease')) {
        $categories['Rental']++;
    } else {
        $categories['House']++;
    }
}

$reqTotal = count($requirements);
$reqActive = 0;
foreach ($requirements as $r) {
    if (($r['status'] ?? 'active') === 'active') $reqActive++;
}

sendResponse([
    'success' => true,
    'stats' => [
        'totalProperties' => $total,
        'activeProperties' => $active,
        'pendingProperties' => $pending,
        'soldProperties' => $sold,
        'verifiedProperties' => $verified,
        'unverifiedProperties' => $total - $verified,
        'totalViews' => $totalViews,
        'totalEnquiries' => $totalEnquiries,
        'categories' => $categories,
        'buyerRequirementsTotal' => $reqTotal,
        'buyerRequirementsActive' => $reqActive,
        'timestamp' => date('c')
    ]
]);
