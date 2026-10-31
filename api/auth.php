<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $username = trim($input['username'] ?? '');
    $password = trim($input['password'] ?? '');

    if (empty($username) || empty($password)) {
        sendResponse([
            'success' => false,
            'message' => 'பயனர்பெயர் மற்றும் கடவுச்சொல் தேவை (Username and password are required).'
        ], 400);
    }

    // Check credentials for super admin
    if ($username === SUPER_ADMIN_USER && $password === SUPER_ADMIN_PASS) {
        // Generate secure session token
        $token = 'tk_admin_' . bin2hex(random_bytes(16)) . '_' . time();
        
        sendResponse([
            'success' => true,
            'message' => 'Super Admin உள்நுழைவு வெற்றிகரமாக முடிந்தது! (Login successful)',
            'token' => $token,
            'user' => [
                'id' => 'admin_super_1',
                'username' => SUPER_ADMIN_USER,
                'role' => 'Super Admin',
                'name' => 'Tenkasi Dreams Administrator',
                'avatar' => 'admin_avatar',
                'permissions' => ['all', 'manage_properties', 'verify_ads', 'manage_requirements', 'view_analytics', 'delete_ads']
            ]
        ], 200);
    } else {
        sendResponse([
            'success' => false,
            'message' => 'தவறான பயனர் பெயர் அல்லது கடவுச்சொல்! (Invalid username or password)'
        ], 401);
    }
} elseif ($method === 'GET') {
    // Token verification or status check
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (!empty($authHeader) && str_starts_with($authHeader, 'Bearer tk_admin_')) {
        sendResponse([
            'success' => true,
            'authenticated' => true,
            'user' => [
                'username' => SUPER_ADMIN_USER,
                'role' => 'Super Admin',
                'name' => 'Tenkasi Dreams Administrator'
            ]
        ], 200);
    } else {
        sendResponse([
            'success' => true,
            'authenticated' => false,
            'message' => 'Not authenticated'
        ], 200);
    }
} else {
    sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}
