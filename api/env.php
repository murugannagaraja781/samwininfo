<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$envPath = __DIR__ . '/.env';

// Helper to write complete raw env file
function saveEnvFile($path, $v) {
    $content = "# ==========================================================\n";
    $content .= "# Tenkasi Dreams Land - Environment & White-Label Configuration (.env)\n";
    $content .= "# Generated / Updated on: " . date('Y-m-d H:i:s') . "\n";
    $content .= "# ==========================================================\n\n";

    $content .= "# 1. Database Connection (MySQL / MariaDB / XAMPP / cPanel)\n";
    $content .= "DB_HOST=" . ($v['DB_HOST'] ?? 'localhost') . "\n";
    $content .= "DB_PORT=" . ($v['DB_PORT'] ?? '3306') . "\n";
    $content .= "DB_NAME=" . ($v['DB_NAME'] ?? 'tenkasi_dreams') . "\n";
    $content .= "DB_USER=" . ($v['DB_USER'] ?? 'root') . "\n";
    $content .= "DB_PASS=" . ($v['DB_PASS'] ?? '') . "\n\n";

    $content .= "# 2. Global Super Admin Authentication\n";
    $content .= "SUPER_ADMIN_USER=" . ($v['SUPER_ADMIN_USER'] ?? 'admin3') . "\n";
    $content .= "SUPER_ADMIN_PASS=" . ($v['SUPER_ADMIN_PASS'] ?? '000003') . "\n";
    $content .= "SESSION_LIFETIME_HOURS=" . ($v['SESSION_LIFETIME_HOURS'] ?? '24') . "\n";
    $content .= "LOGIN_METHOD=\"" . ($v['LOGIN_METHOD'] ?? 'both') . "\"\n\n";

    $content .= "# 3. White-Label Branding & Identity\n";
    $content .= "APP_NAME=\"" . ($v['APP_NAME'] ?? 'Tenkasi Dreams Land') . "\"\n";
    $content .= "APP_TAGLINE=\"" . ($v['APP_TAGLINE'] ?? 'தென்காசி கனவுகள் - ரியல் எஸ்டேட் நிர்வாகம்') . "\"\n";
    $content .= "APP_LOGO_EMOJI=\"" . ($v['APP_LOGO_EMOJI'] ?? '🏛️') . "\"\n";
    $content .= "APP_LOGO_URL=\"" . ($v['APP_LOGO_URL'] ?? '') . "\"\n";
    $content .= "APP_FAVICON_URL=\"" . ($v['APP_FAVICON_URL'] ?? '') . "\"\n";
    $content .= "HERO_BANNER_URL=\"" . ($v['HERO_BANNER_URL'] ?? '') . "\"\n";
    $content .= "PRIMARY_COLOR=\"" . ($v['PRIMARY_COLOR'] ?? '#10B981') . "\"\n";
    $content .= "ACCENT_COLOR=\"" . ($v['ACCENT_COLOR'] ?? '#F59E0B') . "\"\n";
    $content .= "COMPANY_NAME=\"" . ($v['COMPANY_NAME'] ?? 'Tenkasi Dreams Real Estate Group') . "\"\n";
    $content .= "FOOTER_COPYRIGHT=\"" . ($v['FOOTER_COPYRIGHT'] ?? '© 2026 Tenkasi Dreams Land. All Rights Reserved.') . "\"\n\n";

    $content .= "# 4. Contact & Social Media Information\n";
    $content .= "ADMIN_NAME=\"" . ($v['ADMIN_NAME'] ?? 'Murugan Nagarajan') . "\"\n";
    $content .= "ADMIN_PHONE=\"" . ($v['ADMIN_PHONE'] ?? '+91 98941 74944') . "\"\n";
    $content .= "ADMIN_EMAIL=\"" . ($v['ADMIN_EMAIL'] ?? 'tenkasidreams@gmail.com') . "\"\n";
    $content .= "WHATSAPP_NUMBER=\"" . ($v['WHATSAPP_NUMBER'] ?? '+91 98941 74944') . "\"\n";
    $content .= "OFFICE_LOCATION=\"" . ($v['OFFICE_LOCATION'] ?? 'Tenkasi, Tamil Nadu') . "\"\n";
    $content .= "OFFICE_ADDRESS=\"" . ($v['OFFICE_ADDRESS'] ?? 'Main Road, Courtallam Junction, Tenkasi - 627811') . "\"\n";
    $content .= "SOCIAL_FACEBOOK=\"" . ($v['SOCIAL_FACEBOOK'] ?? '') . "\"\n";
    $content .= "SOCIAL_YOUTUBE=\"" . ($v['SOCIAL_YOUTUBE'] ?? '') . "\"\n";
    $content .= "SOCIAL_TELEGRAM=\"" . ($v['SOCIAL_TELEGRAM'] ?? '') . "\"\n\n";

    $content .= "# 5. System & Storage Settings\n";
    $content .= "APP_ENV=" . ($v['APP_ENV'] ?? 'development') . "\n";
    $content .= "APP_URL=" . ($v['APP_URL'] ?? 'http://localhost/land') . "\n";
    $content .= "API_ONLINE_MODE=" . ($v['API_ONLINE_MODE'] ?? 'true') . "\n";
    $content .= "STORAGE_MODE=" . ($v['STORAGE_MODE'] ?? 'auto') . "\n";
    $content .= "DEFAULT_CITY=\"" . ($v['DEFAULT_CITY'] ?? 'Tenkasi') . "\"\n\n";

    $content .= "# 6. Monetization & Razorpay Payment Gateway\n";
    $content .= "RAZORPAY_MODE=\"" . ($v['RAZORPAY_MODE'] ?? 'test') . "\"\n";
    $content .= "RAZORPAY_ACCOUNT_ID=\"" . ($v['RAZORPAY_ACCOUNT_ID'] ?? 'acc_Tdw7B4Z0zFh95x') . "\"\n";
    $content .= "RAZORPAY_LIVE_KEY_ID=\"" . ($v['RAZORPAY_LIVE_KEY_ID'] ?? '') . "\"\n";
    $content .= "RAZORPAY_LIVE_KEY_SECRET=\"" . ($v['RAZORPAY_LIVE_KEY_SECRET'] ?? '') . "\"\n";
    $content .= "RAZORPAY_TEST_KEY_ID=\"" . ($v['RAZORPAY_TEST_KEY_ID'] ?? 'rzp_test_TeE2LFCxmmioPq') . "\"\n";
    $content .= "RAZORPAY_TEST_KEY_SECRET=\"" . ($v['RAZORPAY_TEST_KEY_SECRET'] ?? 'bxk4gdsx48aBSjVSJd61IjLe') . "\"\n";
    $content .= "RAZORPAY_KEY_ID=\"" . ($v['RAZORPAY_KEY_ID'] ?? 'rzp_test_TeE2LFCxmmioPq') . "\"\n";
    $content .= "RAZORPAY_KEY_SECRET=\"" . ($v['RAZORPAY_KEY_SECRET'] ?? 'bxk4gdsx48aBSjVSJd61IjLe') . "\"\n";
    $content .= "UPI_ID=\"" . ($v['UPI_ID'] ?? '9894174944@upi') . "\"\n";
    $content .= "CONTACT_UNLOCK_PRICE=" . ($v['CONTACT_UNLOCK_PRICE'] ?? 30) . "\n";
    $content .= "FREE_CONTACT_LIMIT=" . ($v['FREE_CONTACT_LIMIT'] ?? 3) . "\n";
    $content .= "UNLOCK_CONTACTS_COUNT=" . ($v['UNLOCK_CONTACTS_COUNT'] ?? 1) . "\n";
    $content .= "OFFER_ACTIVE=" . ((!empty($v['OFFER_ACTIVE']) && ($v['OFFER_ACTIVE'] === true || $v['OFFER_ACTIVE'] === 'true')) ? 'true' : 'false') . "\n";
    $content .= "OFFER_UNLOCK_PRICE=" . ($v['OFFER_UNLOCK_PRICE'] ?? 10) . "\n";
    $content .= "OFFER_CONTACTS_COUNT=" . ($v['OFFER_CONTACTS_COUNT'] ?? 1) . "\n";
    $content .= "OFFER_BANNER_TEXT=\"" . ($v['OFFER_BANNER_TEXT'] ?? 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!') . "\"\n";

    file_put_contents($path, $content);
}

switch ($method) {
    case 'GET':
        $envData = loadEnvFile($envPath);
        $rawContent = file_exists($envPath) ? file_get_contents($envPath) : '';

        sendResponse([
            'success' => true,
            'config' => [
                // Database
                'DB_HOST' => $envData['DB_HOST'] ?? 'localhost',
                'DB_PORT' => $envData['DB_PORT'] ?? '3306',
                'DB_NAME' => $envData['DB_NAME'] ?? 'tenkasi_dreams',
                'DB_USER' => $envData['DB_USER'] ?? 'root',
                'DB_PASS' => $envData['DB_PASS'] ?? '',
                
                // Auth
                'SUPER_ADMIN_USER' => $envData['SUPER_ADMIN_USER'] ?? 'admin3',
                'SUPER_ADMIN_PASS' => $envData['SUPER_ADMIN_PASS'] ?? '000003',
                'SESSION_LIFETIME_HOURS' => $envData['SESSION_LIFETIME_HOURS'] ?? '24',
                'LOGIN_METHOD' => $envData['LOGIN_METHOD'] ?? 'both',

                // White-Label & Branding
                'APP_NAME' => $envData['APP_NAME'] ?? 'Tenkasi Dreams Land',
                'APP_TAGLINE' => $envData['APP_TAGLINE'] ?? 'தென்காசி கனவுகள் - ரியல் எஸ்டேட் நிர்வாகம்',
                'APP_LOGO_EMOJI' => $envData['APP_LOGO_EMOJI'] ?? '🏛️',
                'APP_LOGO_URL' => $envData['APP_LOGO_URL'] ?? '',
                'APP_FAVICON_URL' => $envData['APP_FAVICON_URL'] ?? '',
                'HERO_BANNER_URL' => $envData['HERO_BANNER_URL'] ?? '',
                'PRIMARY_COLOR' => $envData['PRIMARY_COLOR'] ?? '#10B981',
                'ACCENT_COLOR' => $envData['ACCENT_COLOR'] ?? '#F59E0B',
                'COMPANY_NAME' => $envData['COMPANY_NAME'] ?? 'Tenkasi Dreams Real Estate Group',
                'FOOTER_COPYRIGHT' => $envData['FOOTER_COPYRIGHT'] ?? '© 2026 Tenkasi Dreams Land. All Rights Reserved.',

                // Contacts & Social
                'ADMIN_NAME' => $envData['ADMIN_NAME'] ?? 'Murugan Nagarajan',
                'ADMIN_PHONE' => $envData['ADMIN_PHONE'] ?? '+91 98941 74944',
                'ADMIN_EMAIL' => $envData['ADMIN_EMAIL'] ?? 'tenkasidreams@gmail.com',
                'WHATSAPP_NUMBER' => $envData['WHATSAPP_NUMBER'] ?? '+91 98941 74944',
                'OFFICE_LOCATION' => $envData['OFFICE_LOCATION'] ?? 'Tenkasi, Tamil Nadu',
                'OFFICE_ADDRESS' => $envData['OFFICE_ADDRESS'] ?? 'Main Road, Courtallam Junction, Tenkasi - 627811',
                'SOCIAL_FACEBOOK' => $envData['SOCIAL_FACEBOOK'] ?? '',
                'SOCIAL_YOUTUBE' => $envData['SOCIAL_YOUTUBE'] ?? '',
                'SOCIAL_TELEGRAM' => $envData['SOCIAL_TELEGRAM'] ?? '',

                // System
                'APP_ENV' => $envData['APP_ENV'] ?? 'development',
                'APP_URL' => $envData['APP_URL'] ?? 'http://localhost/land',
                'STORAGE_MODE' => $envData['STORAGE_MODE'] ?? 'auto',
                'DEFAULT_CITY' => $envData['DEFAULT_CITY'] ?? 'Tenkasi',

                // Monetization & Razorpay
                'RAZORPAY_MODE' => $envData['RAZORPAY_MODE'] ?? 'test',
                'RAZORPAY_ACCOUNT_ID' => $envData['RAZORPAY_ACCOUNT_ID'] ?? 'acc_Tdw7B4Z0zFh95x',
                'RAZORPAY_LIVE_KEY_ID' => $envData['RAZORPAY_LIVE_KEY_ID'] ?? '',
                'RAZORPAY_LIVE_KEY_SECRET' => $envData['RAZORPAY_LIVE_KEY_SECRET'] ?? '',
                'RAZORPAY_TEST_KEY_ID' => $envData['RAZORPAY_TEST_KEY_ID'] ?? 'rzp_test_TeE2LFCxmmioPq',
                'RAZORPAY_TEST_KEY_SECRET' => $envData['RAZORPAY_TEST_KEY_SECRET'] ?? 'bxk4gdsx48aBSjVSJd61IjLe',
                'RAZORPAY_KEY_ID' => $envData['RAZORPAY_KEY_ID'] ?? 'rzp_test_TeE2LFCxmmioPq',
                'RAZORPAY_KEY_SECRET' => $envData['RAZORPAY_KEY_SECRET'] ?? 'bxk4gdsx48aBSjVSJd61IjLe',
                'UPI_ID' => $envData['UPI_ID'] ?? '9894174944@upi',
                'CONTACT_UNLOCK_PRICE' => (int)($envData['CONTACT_UNLOCK_PRICE'] ?? 30),
                'FREE_CONTACT_LIMIT' => (int)($envData['FREE_CONTACT_LIMIT'] ?? 3),
                'UNLOCK_CONTACTS_COUNT' => (int)($envData['UNLOCK_CONTACTS_COUNT'] ?? 1),
                'OFFER_ACTIVE' => strtolower((string)($envData['OFFER_ACTIVE'] ?? 'false')) === 'true',
                'OFFER_UNLOCK_PRICE' => (int)($envData['OFFER_UNLOCK_PRICE'] ?? 10),
                'OFFER_CONTACTS_COUNT' => (int)($envData['OFFER_CONTACTS_COUNT'] ?? 1),
                'OFFER_BANNER_TEXT' => $envData['OFFER_BANNER_TEXT'] ?? 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!'
            ],
            'raw' => $rawContent,
            'env_file_path' => $envPath
        ]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $action = $_GET['action'] ?? $input['action'] ?? 'save';

        // 1. Action: Upload Brand Image (Logo, Favicon, Hero Banner)
        if ($action === 'upload_image') {
            $type = $input['type'] ?? 'logo'; // logo, favicon, banner
            $base64 = $input['image_base64'] ?? null;

            if (!$base64 && isset($_FILES['image_file'])) {
                $file = $_FILES['image_file'];
                if ($file['error'] === UPLOAD_ERR_OK) {
                    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
                    $filename = $type . '_' . time() . '.' . $ext;
                    $targetPath = UPLOADS_DIR . '/' . $filename;
                    if (move_uploaded_file($file['tmp_name'], $targetPath)) {
                        $relativeUrl = '../api/uploads/' . $filename;
                        
                        // Auto-update .env with new image URL
                        $current = loadEnvFile($envPath);
                        if ($type === 'logo') $current['APP_LOGO_URL'] = $relativeUrl;
                        elseif ($type === 'favicon') $current['APP_FAVICON_URL'] = $relativeUrl;
                        elseif ($type === 'banner') $current['HERO_BANNER_URL'] = $relativeUrl;
                        saveEnvFile($envPath, $current);

                        sendResponse([
                            'success' => true,
                            'message' => 'படம் வெற்றிகரமாக பதிவேற்றப்பட்டது! (Image uploaded successfully)',
                            'url' => $relativeUrl,
                            'type' => $type
                        ]);
                    }
                }
            } elseif ($base64) {
                // Base64 image payload
                if (preg_match('/^data:image\/(\w+);base64,/', $base64, $typeMatch)) {
                    $data = substr($base64, strpos($base64, ',') + 1);
                    $ext = strtolower($typeMatch[1]);
                    if ($ext === 'jpeg') $ext = 'jpg';
                    $data = base64_decode($data);
                    $filename = $type . '_' . time() . '.' . $ext;
                    file_put_contents(UPLOADS_DIR . '/' . $filename, $data);
                    $relativeUrl = '../api/uploads/' . $filename;

                    $current = loadEnvFile($envPath);
                    if ($type === 'logo') $current['APP_LOGO_URL'] = $relativeUrl;
                    elseif ($type === 'favicon') $current['APP_FAVICON_URL'] = $relativeUrl;
                    elseif ($type === 'banner') $current['HERO_BANNER_URL'] = $relativeUrl;
                    saveEnvFile($envPath, $current);

                    sendResponse([
                        'success' => true,
                        'message' => 'படம் வெற்றிகரமாக பதிவேற்றப்பட்டது! (Image saved)',
                        'url' => $relativeUrl,
                        'type' => $type
                    ]);
                }
            }
            sendResponse(['success' => false, 'message' => 'படம் பதிவேற்றம் தோல்வி (Image upload failed)'], 400);
        }

        // 2. Action: Test Database Connection
        if ($action === 'test_db') {
            $host = trim($input['DB_HOST'] ?? DB_HOST);
            $port = trim($input['DB_PORT'] ?? DB_PORT ?: '3306');
            $name = trim($input['DB_NAME'] ?? DB_NAME);
            $user = trim($input['DB_USER'] ?? DB_USER);
            $pass = $input['DB_PASS'] ?? DB_PASS;

            try {
                $dsn = "mysql:host=$host;port=$port;dbname=$name;charset=utf8mb4";
                $pdo = new PDO($dsn, $user, $pass, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_TIMEOUT => 3
                ]);
                $version = $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);

                sendResponse([
                    'success' => true,
                    'connected' => true,
                    'message' => "MySQL டேட்டாபேஸ் இணைப்பு வெற்றிகரமாக முடிந்தது! (Connected to MySQL $version successfully)",
                    'server_info' => "MySQL $version on $host:$port/$name"
                ]);
            } catch (Exception $e) {
                sendResponse([
                    'success' => false,
                    'connected' => false,
                    'message' => "டேட்டாபேஸ் இணைப்பு தோல்வி: " . $e->getMessage(),
                    'error_details' => $e->getMessage()
                ], 400);
            }
        }

        // 3. Action: Raw .env Save
        if ($action === 'save_raw') {
            $rawContent = $input['raw'] ?? '';
            if (empty($rawContent)) {
                sendResponse(['success' => false, 'message' => 'Raw content cannot be empty'], 400);
            }
            file_put_contents($envPath, $rawContent);
            loadEnvFile($envPath);

            sendResponse([
                'success' => true,
                'message' => '.env கோப்பு வெற்றிகரமாக புதுப்பிக்கப்பட்டது! (.env saved successfully)'
            ]);
        }

        // 4. Action: Reset to Defaults
        if ($action === 'reset') {
            $defaults = [
                'DB_HOST' => 'localhost',
                'DB_PORT' => '3306',
                'DB_NAME' => 'tenkasi_dreams',
                'DB_USER' => 'root',
                'DB_PASS' => '',
                'SUPER_ADMIN_USER' => 'admin3',
                'SUPER_ADMIN_PASS' => '000003',
                'SESSION_LIFETIME_HOURS' => '24',
                'APP_NAME' => 'Tenkasi Dreams Land',
                'APP_TAGLINE' => 'தென்காசி கனவுகள் - ரியல் எஸ்டேட் நிர்வாகம்',
                'APP_LOGO_EMOJI' => '🏛️',
                'APP_LOGO_URL' => '',
                'APP_FAVICON_URL' => '',
                'HERO_BANNER_URL' => '',
                'PRIMARY_COLOR' => '#10B981',
                'ACCENT_COLOR' => '#F59E0B',
                'COMPANY_NAME' => 'Tenkasi Dreams Real Estate Group',
                'FOOTER_COPYRIGHT' => '© 2026 Tenkasi Dreams Land. All Rights Reserved.',
                'ADMIN_NAME' => 'Murugan Nagarajan',
                'ADMIN_PHONE' => '+91 98941 74944',
                'ADMIN_EMAIL' => 'tenkasidreams@gmail.com',
                'WHATSAPP_NUMBER' => '+91 98941 74944',
                'OFFICE_LOCATION' => 'Tenkasi, Tamil Nadu',
                'OFFICE_ADDRESS' => 'Main Road, Courtallam Junction, Tenkasi - 627811',
                'SOCIAL_FACEBOOK' => '',
                'SOCIAL_YOUTUBE' => '',
                'SOCIAL_TELEGRAM' => '',
                'APP_ENV' => 'development',
                'APP_URL' => 'http://localhost/land',
                'STORAGE_MODE' => 'auto',
                'CURRENCY_SYMBOL' => '₹',
                'DEFAULT_CITY' => 'Tenkasi',
                'RAZORPAY_ACCOUNT_ID' => 'acc_Tdw7B4Z0zFh95x',
                'RAZORPAY_KEY_ID' => 'acc_Tdw7B4Z0zFh95x',
                'RAZORPAY_KEY_SECRET' => 'Tdw7B4Z0zFh95x',
                'CONTACT_UNLOCK_PRICE' => 30,
                'FREE_CONTACT_LIMIT' => 3,
                'UNLOCK_CONTACTS_COUNT' => 1,
                'OFFER_ACTIVE' => false,
                'OFFER_UNLOCK_PRICE' => 10,
                'OFFER_CONTACTS_COUNT' => 1,
                'OFFER_BANNER_TEXT' => 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!'
            ];
            saveEnvFile($envPath, $defaults);
            loadEnvFile($envPath);

            sendResponse([
                'success' => true,
                'message' => 'அமைப்புகள் ஆரம்ப நிலைக்கு மாற்றப்பட்டன (Reset to default .env)!',
                'config' => $defaults
            ]);
        }

        // 5. Action: Save Form Variables
        $current = loadEnvFile($envPath);
        $merged = array_merge($current, $input);
        unset($merged['action']);

        saveEnvFile($envPath, $merged);
        loadEnvFile($envPath);

        sendResponse([
            'success' => true,
            'message' => 'ஒயிட் லேபில் மற்றும் சுற்றுச்சூழல் அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன! (White-label settings saved)',
            'config' => $merged
        ]);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}
