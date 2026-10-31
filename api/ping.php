<?php
if (function_exists('opcache_reset')) {
    @opcache_reset();
}
require_once __DIR__ . '/config.php';

$dbStatus = getDbConnection() !== null ? 'MySQL Connected' : 'JSON Storage Active';

sendResponse([
    'success' => true,
    'app' => 'Tenkasi Dreams Land Super Admin API',
    'version' => '2.0.0',
    'status' => 'online',
    'storage' => $dbStatus,
    'super_admin' => SUPER_ADMIN_USER,
    'razorpay_key_id' => defined('RAZORPAY_KEY_ID') ? RAZORPAY_KEY_ID : 'not_defined',
    'env_file_api' => file_exists(__DIR__ . '/.env'),
    'env_file_root' => file_exists(dirname(__DIR__) . '/.env'),
    'env_content' => file_exists(__DIR__ . '/.env') ? substr(file_get_contents(__DIR__ . '/.env'), 0, 300) : '',
    'server_time' => date('Y-m-d H:i:s')
]);
