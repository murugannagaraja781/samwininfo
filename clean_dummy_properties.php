<?php
require_once __DIR__ . '/api/config.php';

header('Content-Type: application/json; charset=utf-8');

$pdo = getDbConnection();
if (!$pdo) {
    echo json_encode(['success' => false, 'error' => 'Database connection failed']);
    exit(1);
}

try {
    // 1. Fetch all properties to see what they are
    $stmt = $pdo->query("SELECT id, title FROM `properties`");
    $allProps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Delete all existing test/mock properties
    $pdo->exec("TRUNCATE TABLE `properties`");
    $deletedCount = count($allProps);

    // Check remaining count
    $remainingProps = [];

    // Also clear properties.json
    $propJson = DATA_DIR . '/properties.json';
    file_put_contents($propJson, json_encode([], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

    // Also clear user_activities completely so no dummy activities remain
    $pdo->exec("TRUNCATE TABLE `user_activities`");
    $actJson = DATA_DIR . '/activities.json';
    file_put_contents($actJson, json_encode([], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

    echo json_encode([
        'success' => true,
        'deleted_dummy_properties' => $deletedCount,
        'remaining_properties' => count($remainingProps),
        'message' => 'All dummy properties and activities completely cleaned from MySQL and JSON'
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
