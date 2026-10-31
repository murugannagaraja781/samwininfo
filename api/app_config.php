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
$envPath = __DIR__ . '/.env';

switch ($method) {
    case 'GET':
        $env = loadEnvFile($envPath);
        
        $loginMethod = strtolower(trim($env['LOGIN_METHOD'] ?? 'google'));
        if (!in_array($loginMethod, ['google', 'phone', 'both'])) {
            $loginMethod = 'google';
        }

        $googleEnabled = true;
        $phoneEnabled = false;

        if ($loginMethod === 'google') {
            $googleEnabled = true;
            $phoneEnabled = false;
        } elseif ($loginMethod === 'phone') {
            $googleEnabled = false;
            $phoneEnabled = true;
        } elseif ($loginMethod === 'both') {
            $googleEnabled = true;
            $phoneEnabled = true;
        }

        // Also check explicit flags if set
        if (isset($env['GOOGLE_SIGN_IN_ENABLED'])) {
            $googleEnabled = strtolower((string)$env['GOOGLE_SIGN_IN_ENABLED']) === 'true';
        }
        if (isset($env['PHONE_OTP_ENABLED'])) {
            $phoneEnabled = strtolower((string)$env['PHONE_OTP_ENABLED']) === 'true';
        }

        sendResponse([
            'success' => true,
            'config' => [
                'login_method' => $loginMethod,
                'google_sign_in_enabled' => $googleEnabled,
                'phone_otp_enabled' => $phoneEnabled,
                'free_contact_limit' => (int)($env['FREE_CONTACT_LIMIT'] ?? 3),
                'contact_unlock_price' => (int)($env['CONTACT_UNLOCK_PRICE'] ?? 30),
                'offer_active' => strtolower((string)($env['OFFER_ACTIVE'] ?? 'false')) === 'true',
                'offer_unlock_price' => (int)($env['OFFER_UNLOCK_PRICE'] ?? 10),
                'offer_contacts_count' => (int)($env['OFFER_CONTACTS_COUNT'] ?? 1),
                'razorpay_mode' => defined('RAZORPAY_MODE') ? RAZORPAY_MODE : 'test',
                'razorpay_account_id' => defined('RAZORPAY_ACCOUNT_ID') ? RAZORPAY_ACCOUNT_ID : ($env['RAZORPAY_ACCOUNT_ID'] ?? 'acc_Tdw7B4Z0zFh95x'),
                'razorpay_key_id' => defined('RAZORPAY_KEY_ID') ? RAZORPAY_KEY_ID : ($env['RAZORPAY_KEY_ID'] ?? 'rzp_test_TeE2LFCxmmioPq'),
                'upi_id' => defined('UPI_ID') ? UPI_ID : ($env['UPI_ID'] ?? '9894174944@upi'),
                'app_name' => $env['APP_NAME'] ?? 'Tenkasi Dreams Land',
                'app_tagline' => $env['APP_TAGLINE'] ?? 'தென்காசி கனவுகள் - ரியல் எஸ்டேட் நிர்வாகம்',
                'admin_phone' => $env['ADMIN_PHONE'] ?? '+91 98941 74944',
                'whatsapp_number' => $env['WHATSAPP_NUMBER'] ?? '+91 98941 74944',
                'primary_color' => $env['PRIMARY_COLOR'] ?? '#10B981',
                'default_city' => $env['DEFAULT_CITY'] ?? 'Tenkasi'
            ]
        ]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $currentEnv = loadEnvFile($envPath);

        // Update login method
        if (isset($input['login_method'])) {
            $methodVal = strtolower(trim($input['login_method']));
            if (in_array($methodVal, ['google', 'phone', 'both'])) {
                $currentEnv['LOGIN_METHOD'] = $methodVal;
                if ($methodVal === 'google') {
                    $currentEnv['GOOGLE_SIGN_IN_ENABLED'] = 'true';
                    $currentEnv['PHONE_OTP_ENABLED'] = 'false';
                } elseif ($methodVal === 'phone') {
                    $currentEnv['GOOGLE_SIGN_IN_ENABLED'] = 'false';
                    $currentEnv['PHONE_OTP_ENABLED'] = 'true';
                } elseif ($methodVal === 'both') {
                    $currentEnv['GOOGLE_SIGN_IN_ENABLED'] = 'true';
                    $currentEnv['PHONE_OTP_ENABLED'] = 'true';
                }
            }
        }

        if (isset($input['google_sign_in_enabled'])) {
            $currentEnv['GOOGLE_SIGN_IN_ENABLED'] = !empty($input['google_sign_in_enabled']) ? 'true' : 'false';
        }
        if (isset($input['phone_otp_enabled'])) {
            $currentEnv['PHONE_OTP_ENABLED'] = !empty($input['phone_otp_enabled']) ? 'true' : 'false';
        }

        if (isset($input['free_contact_limit'])) {
            $currentEnv['FREE_CONTACT_LIMIT'] = (int)$input['free_contact_limit'];
        }
        if (isset($input['contact_unlock_price'])) {
            $currentEnv['CONTACT_UNLOCK_PRICE'] = (int)$input['contact_unlock_price'];
        }
        if (isset($input['offer_active'])) {
            $currentEnv['OFFER_ACTIVE'] = !empty($input['offer_active']) ? 'true' : 'false';
        }
        if (isset($input['offer_unlock_price'])) {
            $currentEnv['OFFER_UNLOCK_PRICE'] = (int)$input['offer_unlock_price'];
        }
        if (isset($input['offer_banner_text'])) {
            $currentEnv['OFFER_BANNER_TEXT'] = trim($input['offer_banner_text']);
        }
        if (isset($input['razorpay_account_id'])) {
            $currentEnv['RAZORPAY_ACCOUNT_ID'] = trim($input['razorpay_account_id']);
        }
        if (isset($input['razorpay_key_id'])) {
            $currentEnv['RAZORPAY_KEY_ID'] = trim($input['razorpay_key_id']);
        }
        if (isset($input['razorpay_key_secret'])) {
            $currentEnv['RAZORPAY_KEY_SECRET'] = trim($input['razorpay_key_secret']);
        }

        // Save into .env
        require_once __DIR__ . '/env.php';
        saveEnvFile($envPath, $currentEnv);
        loadEnvFile($envPath);

        sendResponse([
            'success' => true,
            'message' => 'செயலி அமைப்புகள் (App Configuration) வெற்றிகரமாக சேமிக்கப்பட்டன!',
            'config' => [
                'login_method' => $currentEnv['LOGIN_METHOD'] ?? 'google',
                'google_sign_in_enabled' => ($currentEnv['GOOGLE_SIGN_IN_ENABLED'] ?? 'true') === 'true',
                'phone_otp_enabled' => ($currentEnv['PHONE_OTP_ENABLED'] ?? 'false') === 'true',
                'free_contact_limit' => (int)($currentEnv['FREE_CONTACT_LIMIT'] ?? 3),
                'contact_unlock_price' => (int)($currentEnv['CONTACT_UNLOCK_PRICE'] ?? 30),
                'offer_active' => ($currentEnv['OFFER_ACTIVE'] ?? 'false') === 'true',
                'offer_unlock_price' => (int)($currentEnv['OFFER_UNLOCK_PRICE'] ?? 10)
            ]
        ]);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
        break;
}
