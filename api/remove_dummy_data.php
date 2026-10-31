<?php
/**
 * Tenkasi Dreams Land - Remove Dummy Properties
 * Keeps only real user / admin ads, removing all seeded test / dummy data.
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/config.php';

$dummyPrefixes = [
    'prop_house_tenkasi_',
    'prop_house_ilanji_',
    'prop_house_pavoor_',
    'prop_land_bypass_',
    'prop_land_surandai_',
    'prop_land_kadayanallur_',
    'prop_farm_mathalamparai_',
    'prop_farm_courtallam_',
    'prop_farm_sengottai_',
    'prop_shop_market_',
    'prop_shop_complex_',
    'prop_apt_town_',
    'prop_rental_railway_',
    'prop_rental_shop_'
];

$dummyTitles = [
    'Rewrite Test',
    'Super Admin Test Ad 1'
];

// 1. Clean JSON storage
$jsonProps = readJsonStorage('properties.json');
if (!is_array($jsonProps)) $jsonProps = [];

$cleanedProps = [];
$removedCount = 0;

foreach ($jsonProps as $p) {
    $id = $p['id'] ?? '';
    $title = $p['title'] ?? '';

    $isDummy = false;
    foreach ($dummyPrefixes as $prefix) {
        if (str_starts_with($id, $prefix)) {
            $isDummy = true;
            break;
        }
    }
    if (in_array($title, $dummyTitles) || empty(trim($title))) {
        $isDummy = true;
    }

    if ($isDummy) {
        $removedCount++;
    } else {
        $cleanedProps[] = $p;
    }
}

writeJsonStorage('properties.json', $cleanedProps);

// 2. Clean MySQL DB if available
$dbRemoved = 0;
$pdo = getDbConnection();
if ($pdo) {
    try {
        $sql = "DELETE FROM `properties` WHERE 
            `id` LIKE 'prop_house_%' OR 
            `id` LIKE 'prop_land_%' OR 
            `id` LIKE 'prop_farm_%' OR 
            `id` LIKE 'prop_shop_%' OR 
            `id` LIKE 'prop_apt_%' OR 
            `id` LIKE 'prop_rental_%' OR 
            `title` = 'Rewrite Test' OR 
            `title` = 'Super Admin Test Ad 1' OR
            TRIM(`title`) = ''";
        $dbRemoved = $pdo->exec($sql);
    } catch (Exception $e) {}
}

echo json_encode([
    'success' => true,
    'message' => 'Dummy data removed successfully! Only real ads remain.',
    'removed_from_json' => $removedCount,
    'removed_from_db' => $dbRemoved,
    'remaining_properties_count' => count($cleanedProps),
    'remaining_properties' => array_map(function($p) {
        return [
            'id' => $p['id'],
            'title' => $p['title'],
            'propertyType' => $p['propertyType'] ?? '',
            'price' => $p['price'] ?? 0,
            'sellerName' => $p['sellerName'] ?? ''
        ];
    }, $cleanedProps)
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
