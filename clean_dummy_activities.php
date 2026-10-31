<?php
require_once __DIR__ . '/api/config.php';

$pdo = getDbConnection();
if ($pdo) {
    try {
        $count = $pdo->exec("DELETE FROM `user_activities` WHERE `user_phone` IN ('9876543210', '7777777777') OR `user_name` IN ('Ravi', 'Test Buyer', 'Customer')");
        echo "Deleted $count dummy rows from user_activities.\n";
    } catch (Exception $e) {
        echo "DB Error: " . $e->getMessage() . "\n";
    }
} else {
    echo "No DB connection.\n";
}
