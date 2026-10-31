<?php
/**
 * Tenkasi Dreams Land - Dynamic Categories & Images API
 * Enables Super Admin to customize category titles, icons, and display images.
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/config.php';

$categoriesFile = DATA_DIR . '/categories.json';

// Default categories with localized Tamil labels and modern assets
$defaultCategories = [
    [
        'id' => 'house',
        'nameTa' => 'வீடு',
        'nameEn' => 'House / Villa',
        'image' => 'assets/images/cat_house.png',
        'icon' => '🏠',
        'badge' => 'தனி வீடு & வில்லா'
    ],
    [
        'id' => 'land',
        'nameTa' => 'நிலம் / மனை',
        'nameEn' => 'Plots & Land',
        'image' => 'assets/images/cat_land.png',
        'icon' => '📐',
        'badge' => 'DTCP & மனை'
    ],
    [
        'id' => 'farmland',
        'nameTa' => 'தோட்டம்',
        'nameEn' => 'Farm & Garden',
        'image' => 'assets/images/cat_farm.png',
        'icon' => '🌴',
        'badge' => 'போர் & இலவச EB'
    ],
    [
        'id' => 'shop',
        'nameTa' => 'கடை / வணிகம்',
        'nameEn' => 'Shop & Commercial',
        'image' => 'assets/images/cat_shop.png',
        'icon' => '🏪',
        'badge' => 'மெயின் ரோடு & பஜார்'
    ],
    [
        'id' => 'apartment',
        'nameTa' => 'அபார்ட்மெண்ட்',
        'nameEn' => 'Apartment & Flat',
        'image' => 'assets/images/cat_apartment.png',
        'icon' => '🏢',
        'badge' => '1, 2, 3 BHK & லிப்ட்'
    ],
    [
        'id' => 'rental',
        'nameTa' => 'வாடகைக்கு',
        'nameEn' => 'Rental Property',
        'image' => 'assets/images/cat_rental.png',
        'icon' => '🔑',
        'badge' => 'வாடகை & லீஸ் (7 வகைகள்)'
    ]
];

function getCategories($file, $defaults) {
    if (!file_exists($file)) {
        file_put_contents($file, json_encode($defaults, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        return $defaults;
    }
    $data = json_decode(file_get_contents($file), true);
    return is_array($data) ? $data : $defaults;
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    $categories = getCategories($categoriesFile, $defaultCategories);
    $loginMethod = defined('LOGIN_METHOD') ? LOGIN_METHOD : ($_ENV['LOGIN_METHOD'] ?? 'both');
    sendResponse([
        'success' => true,
        'categories' => $categories,
        'loginMethod' => $loginMethod
    ]);
}

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    
    // Update category by ID
    $catId = $input['id'] ?? ($_POST['id'] ?? '');
    $newImage = $input['image'] ?? ($_POST['image'] ?? '');
    $newNameTa = $input['nameTa'] ?? ($_POST['nameTa'] ?? '');
    $newNameEn = $input['nameEn'] ?? ($_POST['nameEn'] ?? '');
    $newBadge = $input['badge'] ?? ($_POST['badge'] ?? '');
    
    // Handle File Upload if an image file was submitted
    if (isset($_FILES['image_file']) && $_FILES['image_file']['error'] === UPLOAD_ERR_OK) {
        $catUploadDir = UPLOADS_DIR . '/categories';
        if (!file_exists($catUploadDir)) {
            mkdir($catUploadDir, 0777, true);
        }
        $file = $_FILES['image_file'];
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (in_array($ext, ['png', 'jpg', 'jpeg', 'webp', 'svg'])) {
            $filename = 'cat_' . preg_replace('/[^a-zA-Z0-9_-]/', '', $catId) . '_' . time() . '.' . $ext;
            $dest = $catUploadDir . '/' . $filename;
            if (move_uploaded_file($file['tmp_name'], $dest)) {
                $newImage = 'api/uploads/categories/' . $filename;
            }
        }
    }
    
    if (empty($catId)) {
        sendResponse(['success' => false, 'message' => 'Category ID is required'], 400);
    }
    
    $current = getCategories($categoriesFile, $defaultCategories);
    $updated = false;
    
    foreach ($current as &$cat) {
        if ($cat['id'] === $catId) {
            if (!empty($newImage)) $cat['image'] = $newImage;
            if (!empty($newNameTa)) $cat['nameTa'] = $newNameTa;
            if (!empty($newNameEn)) $cat['nameEn'] = $newNameEn;
            if (!empty($newBadge)) $cat['badge'] = $newBadge;
            $updated = true;
            break;
        }
    }
    
    if ($updated) {
        file_put_contents($categoriesFile, json_encode($current, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        sendResponse([
            'success' => true,
            'message' => 'கேட்டகரி படம் & விவரங்கள் வெற்றிகரமாக சேமிக்கப்பட்டது! (Category updated successfully)',
            'categories' => $current
        ]);
    } else {
        sendResponse(['success' => false, 'message' => 'Category not found'], 404);
    }
}
