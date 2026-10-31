<?php
header('Content-Type: application/json');
$reset = false;
if (function_exists('opcache_reset')) {
    $reset = opcache_reset();
}
echo json_encode([
    'success' => true,
    'opcache_reset' => $reset,
    'server_time' => date('Y-m-d H:i:s')
]);
