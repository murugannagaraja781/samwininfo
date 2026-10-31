<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
if (str_contains($_SERVER['SCRIPT_NAME'] ?? '', '/api/') || str_contains($_SERVER['REQUEST_URI'] ?? '', '/api/')) {
    header('Content-Type: application/json; charset=UTF-8');
}

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(200);
    exit();
}

/**
 * Load environment variables from .env file
 */
function loadEnvFile($envFilePath = null) {
    $envPaths = [];
    if ($envFilePath !== null) {
        $envPaths[] = $envFilePath;
    } else {
        if (file_exists(dirname(__DIR__) . '/.env')) {
            $envPaths[] = dirname(__DIR__) . '/.env';
        }
        if (file_exists(__DIR__ . '/.env')) {
            $envPaths[] = __DIR__ . '/.env';
        }
    }

    $envData = [];
    foreach ($envPaths as $path) {
        if (!file_exists($path)) continue;
        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (empty($line) || str_starts_with($line, '#')) {
                continue;
            }

            if (strpos($line, '=') !== false) {
                list($key, $value) = explode('=', $line, 2);
                $key = trim($key);
                $value = trim($value);
                // Strip surrounding quotes
                if ((str_starts_with($value, '"') && str_ends_with($value, '"')) ||
                    (str_starts_with($value, "'") && str_ends_with($value, "'"))) {
                    $value = substr($value, 1, -1);
                }
                $_ENV[$key] = $value;
                putenv("$key=$value");
                $envData[$key] = $value;
            }
        }
    }
    return $envData;
}

// Load .env at bootstrap
loadEnvFile();

// Database Configuration Constants
define('DB_HOST', $_ENV['DB_HOST'] ?? 'localhost');
define('DB_PORT', $_ENV['DB_PORT'] ?? '3306');
define('DB_NAME', $_ENV['DB_NAME'] ?? 'samwininfo');
define('DB_USER', $_ENV['DB_USER'] ?? 'root');
define('DB_PASS', $_ENV['DB_PASS'] ?? '');

// Super Admin Credentials
define('SUPER_ADMIN_USER', $_ENV['SUPER_ADMIN_USER'] ?? 'admin3');
define('SUPER_ADMIN_PASS', $_ENV['SUPER_ADMIN_PASS'] ?? '000003');

// White-Label Branding Constants
define('APP_NAME', $_ENV['APP_NAME'] ?? 'SamWin');
define('APP_TAGLINE', $_ENV['APP_TAGLINE'] ?? 'தென்காசி கனவுகள் - ரியல் எஸ்டேட் நிர்வாகம்');
define('APP_LOGO_EMOJI', $_ENV['APP_LOGO_EMOJI'] ?? '🏛️');
define('APP_LOGO_URL', $_ENV['APP_LOGO_URL'] ?? '');
define('APP_FAVICON_URL', $_ENV['APP_FAVICON_URL'] ?? '');
define('HERO_BANNER_URL', $_ENV['HERO_BANNER_URL'] ?? '');
define('PRIMARY_COLOR', $_ENV['PRIMARY_COLOR'] ?? '#10B981');
define('ACCENT_COLOR', $_ENV['ACCENT_COLOR'] ?? '#F59E0B');
define('COMPANY_NAME', $_ENV['COMPANY_NAME'] ?? 'SamWin Info Group');
define('FOOTER_COPYRIGHT', $_ENV['FOOTER_COPYRIGHT'] ?? '© 2026 SamWin. All Rights Reserved.');

// Contact & Support Details
define('ADMIN_NAME', $_ENV['ADMIN_NAME'] ?? 'Murugan Nagarajan');
define('ADMIN_PHONE', $_ENV['ADMIN_PHONE'] ?? '+91 98941 74944');
define('ADMIN_EMAIL', $_ENV['ADMIN_EMAIL'] ?? 'info@samwininfo.com');
define('WHATSAPP_NUMBER', $_ENV['WHATSAPP_NUMBER'] ?? '+91 98941 74944');
define('OFFICE_LOCATION', $_ENV['OFFICE_LOCATION'] ?? 'Tenkasi, Tamil Nadu');
define('OFFICE_ADDRESS', $_ENV['OFFICE_ADDRESS'] ?? 'Main Road, Courtallam Junction, Tenkasi - 627811');

// System & Storage
define('APP_ENV', $_ENV['APP_ENV'] ?? 'development');
define('APP_URL', $_ENV['APP_URL'] ?? 'http://localhost/samwininfo');
define('STORAGE_MODE', $_ENV['STORAGE_MODE'] ?? 'auto');
define('CURRENCY_SYMBOL', $_ENV['CURRENCY_SYMBOL'] ?? '₹');

// Monetization & Razorpay Gateway
$razorpayMode = strtolower(trim($_ENV['RAZORPAY_MODE'] ?? 'test'));
$liveKeyId = trim($_ENV['RAZORPAY_LIVE_KEY_ID'] ?? '');
$liveKeySecret = trim($_ENV['RAZORPAY_LIVE_KEY_SECRET'] ?? '');
$testKeyId = trim($_ENV['RAZORPAY_TEST_KEY_ID'] ?? 'rzp_test_TeE2LFCxmmioPq');
$testKeySecret = trim($_ENV['RAZORPAY_TEST_KEY_SECRET'] ?? 'bxk4gdsx48aBSjVSJd61IjLe');

$envKeyId = trim($_ENV['RAZORPAY_KEY_ID'] ?? '');
$envKeySecret = trim($_ENV['RAZORPAY_KEY_SECRET'] ?? '');

$isLiveActive = ($razorpayMode === 'live' && !empty($liveKeyId) && str_starts_with($liveKeyId, 'rzp_live'))
    || ($razorpayMode === 'live' && str_starts_with($envKeyId, 'rzp_live'))
    || str_starts_with($envKeyId, 'rzp_live');

define('RAZORPAY_MODE', $isLiveActive ? 'live' : 'test');
define('RAZORPAY_ACCOUNT_ID', $_ENV['RAZORPAY_ACCOUNT_ID'] ?? 'acc_Tdw7B4Z0zFh95x');
define('RAZORPAY_KEY_ID', $isLiveActive 
    ? (!empty($liveKeyId) ? $liveKeyId : $envKeyId) 
    : ($testKeyId ?: ($envKeyId ?: 'rzp_test_TeE2LFCxmmioPq')));
define('RAZORPAY_KEY_SECRET', $isLiveActive 
    ? (!empty($liveKeySecret) ? $liveKeySecret : $envKeySecret) 
    : ($testKeySecret ?: ($envKeySecret ?: 'bxk4gdsx48aBSjVSJd61IjLe')));
define('UPI_ID', $_ENV['UPI_ID'] ?? '9894174944@upi');
define('CONTACT_UNLOCK_PRICE', (int)($_ENV['CONTACT_UNLOCK_PRICE'] ?? 30));
define('FREE_CONTACT_LIMIT', (int)($_ENV['FREE_CONTACT_LIMIT'] ?? 3));
define('UNLOCK_CONTACTS_COUNT', (int)($_ENV['UNLOCK_CONTACTS_COUNT'] ?? 1));
define('OFFER_ACTIVE', strtolower((string)($_ENV['OFFER_ACTIVE'] ?? 'false')) === 'true');
define('OFFER_UNLOCK_PRICE', (int)($_ENV['OFFER_UNLOCK_PRICE'] ?? 10));
define('OFFER_CONTACTS_COUNT', (int)($_ENV['OFFER_CONTACTS_COUNT'] ?? 1));
define('OFFER_BANNER_TEXT', $_ENV['OFFER_BANNER_TEXT'] ?? 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!');

// Data Directory for JSON fallback storage
define('DATA_DIR', __DIR__ . '/data');
if (!file_exists(DATA_DIR)) {
    mkdir(DATA_DIR, 0777, true);
}

// Uploads Directory for custom logos, banners, watermarks
define('UPLOADS_DIR', __DIR__ . '/uploads');
if (!file_exists(UPLOADS_DIR)) {
    mkdir(UPLOADS_DIR, 0777, true);
}

/**
 * Returns a PDO connection if MySQL database is available, or null to use JSON fallback.
 */
function getDbConnection() {
    static $pdo = null;
    if ($pdo !== null) return $pdo;

    if (STORAGE_MODE === 'json') {
        return null;
    }

    try {
        $port = DB_PORT ?: '3306';
        $dsn = "mysql:host=" . DB_HOST . ";port=" . $port . ";dbname=" . DB_NAME . ";charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_TIMEOUT => 2,
        ];
        $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        return $pdo;
    } catch (Exception $e) {
        // Fall back to JSON file storage mode seamlessly
        return null;
    }
}

/**
 * Helper to read JSON data file
 */
function readJsonStorage($filename) {
    $filePath = DATA_DIR . '/' . $filename;
    if (!file_exists($filePath)) {
        return [];
    }
    $content = file_get_contents($filePath);
    $data = json_decode($content, true);
    return is_array($data) ? $data : [];
}

/**
 * Helper to write JSON data file
 */
function writeJsonStorage($filename, $data) {
    $filePath = DATA_DIR . '/' . $filename;
    file_put_contents($filePath, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

/**
 * Send standard JSON response
 */
function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}
