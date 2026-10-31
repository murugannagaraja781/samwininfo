<?php
/**
 * Tenkasi Dreams Land - MySQL Database Initializer & Migration Tool
 * Automatically creates all tables and seeds default properties into the connected database.
 * Run this once on Hostinger or any MySQL server: http://yourdomain.com/api/init_db.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

if (isset($_GET['check_payments'])) {
    $payFile = __DIR__ . '/payments.php';
    $content = file_exists($payFile) ? file_get_contents($payFile) : '';
    echo json_encode([
        'dir' => __DIR__,
        'file' => __FILE__,
        'pay_file_exists' => file_exists($payFile),
        'pay_file_size' => strlen($content),
        'pay_file_md5' => md5($content),
        'has_create_order' => strpos($content, 'create_order') !== false,
        'has_var_export' => strpos($content, 'var_export') !== false,
        'server_time' => date('Y-m-d H:i:s')
    ]);
    exit();
}

require_once __DIR__ . '/config.php';

$pdo = getDbConnection();
if (!$pdo) {
    echo json_encode([
        'success' => false,
        'message' => 'Could not connect to MySQL database. Check DB_HOST, DB_NAME, DB_USER, DB_PASS in .env',
        'db_host' => DB_HOST,
        'db_name' => DB_NAME,
        'db_user' => DB_USER
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit();
}

$queries = [
    // 1. Admin Users Table
    "CREATE TABLE IF NOT EXISTS `admin_users` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `username` VARCHAR(50) NOT NULL UNIQUE,
        `password` VARCHAR(255) NOT NULL,
        `role` VARCHAR(30) DEFAULT 'super_admin',
        `full_name` VARCHAR(100) NOT NULL,
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;",

    // Seed default Super Admin
    "INSERT INTO `admin_users` (`username`, `password`, `role`, `full_name`) 
     VALUES ('admin3', '000003', 'super_admin', 'Tenkasi Dreams Super Admin')
     ON DUPLICATE KEY UPDATE `password` = '000003';",

    // 2. Properties Table (FULL schema matching JSON structure)
    "CREATE TABLE IF NOT EXISTS `properties` (
        `id` VARCHAR(64) PRIMARY KEY,
        `title` VARCHAR(500) NOT NULL,
        `description` TEXT,
        `price` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
        `location` VARCHAR(200) NOT NULL,
        `city` VARCHAR(80) NOT NULL DEFAULT 'Tenkasi',
        `propertyType` VARCHAR(50) NOT NULL DEFAULT 'Land',
        `areaSqFt` INT NOT NULL DEFAULT 0,
        `superBuiltUpSqFt` INT DEFAULT NULL,
        `carpetAreaSqFt` INT DEFAULT NULL,
        `bedrooms` INT DEFAULT NULL,
        `bathrooms` INT DEFAULT NULL,
        `furnishingStatus` VARCHAR(50) DEFAULT 'Unfurnished',
        `facing` VARCHAR(80) DEFAULT 'East',
        `floor` VARCHAR(80) DEFAULT 'Ground Floor',
        `maintenanceMonthly` DECIMAL(10,2) DEFAULT NULL,
        `landmark` VARCHAR(200) DEFAULT NULL,
        `posterType` VARCHAR(50) DEFAULT 'Direct Owner',
        `landUnit` VARCHAR(50) DEFAULT NULL,
        `landUnitValue` DECIMAL(10,2) DEFAULT NULL,
        `landFeatures` JSON DEFAULT NULL,
        `approvalType` VARCHAR(100) DEFAULT NULL,
        `isBankLoanAvailable` TINYINT(1) DEFAULT 0,
        `isPriceNegotiable` TINYINT(1) DEFAULT 1,
        `waterSource` VARCHAR(50) DEFAULT 'Both',
        `hasLift` TINYINT(1) DEFAULT 0,
        `hasTrees` TINYINT(1) DEFAULT 0,
        `treesDetails` TEXT DEFAULT NULL,
        `hasIncome` TINYINT(1) DEFAULT 0,
        `incomeDetails` TEXT DEFAULT NULL,
        `isLease` TINYINT(1) DEFAULT 0,
        `rentalSubType` VARCHAR(100) DEFAULT NULL,
        `advanceAmount` DECIMAL(12,2) DEFAULT NULL,
        `commercialAreaType` VARCHAR(100) DEFAULT NULL,
        `hasTable` TINYINT(1) DEFAULT 0,
        `hasFan` TINYINT(1) DEFAULT 0,
        `hasWaterSupply` TINYINT(1) DEFAULT 0,
        `hasShutter` TINYINT(1) DEFAULT 0,
        `powerPhase` VARCHAR(50) DEFAULT NULL,
        `contactPhone` VARCHAR(30) DEFAULT '+91 98941 74944',
        `sellerName` VARCHAR(200) DEFAULT 'Direct Owner',
        `sellerPhone` VARCHAR(30) DEFAULT '+91 98941 74944',
        `imageKeys` JSON DEFAULT NULL,
        `imageUrls` JSON DEFAULT NULL,
        `amenities` JSON DEFAULT NULL,
        `agent_id` VARCHAR(64) DEFAULT NULL,
        `agent_name` VARCHAR(200) DEFAULT NULL,
        `agent_agencyName` VARCHAR(200) DEFAULT NULL,
        `agent_phone` VARCHAR(30) DEFAULT NULL,
        `agent_email` VARCHAR(120) DEFAULT NULL,
        `postedDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `status` VARCHAR(30) DEFAULT 'active',
        `isFavorite` TINYINT(1) DEFAULT 0,
        `isVerified` TINYINT(1) DEFAULT 1,
        `isFeatured` TINYINT(1) DEFAULT 0,
        `isPremium` TINYINT(1) DEFAULT 0,
        `isUserPosted` TINYINT(1) DEFAULT 0,
        `views` INT DEFAULT 0,
        `enquiries` INT DEFAULT 0,
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;",

    // Ensure isPremium column exists for existing tables
    "ALTER TABLE `properties` ADD COLUMN IF NOT EXISTS `isPremium` TINYINT(1) DEFAULT 0;",

    // 3. Buyer Requirements Table
    "CREATE TABLE IF NOT EXISTS `buyer_requirements` (
        `id` VARCHAR(64) PRIMARY KEY,
        `userName` VARCHAR(100) NOT NULL,
        `userPhone` VARCHAR(30) NOT NULL,
        `propertyType` VARCHAR(50) NOT NULL,
        `targetLocation` VARCHAR(150) NOT NULL,
        `budgetMin` DECIMAL(14,2) DEFAULT NULL,
        `budgetMax` DECIMAL(14,2) DEFAULT NULL,
        `preferredSize` VARCHAR(100) DEFAULT NULL,
        `facingPreference` VARCHAR(50) DEFAULT NULL,
        `description` TEXT,
        `status` VARCHAR(30) DEFAULT 'active',
        `postedDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;",

    // 4. Land Payments Table (prefixed to avoid collision with existing billing payments)
    "CREATE TABLE IF NOT EXISTS `land_payments` (
        `id` VARCHAR(64) PRIMARY KEY,
        `paymentId` VARCHAR(100) DEFAULT NULL,
        `orderId` VARCHAR(100) DEFAULT NULL,
        `propId` VARCHAR(64) DEFAULT NULL,
        `propTitle` VARCHAR(255) DEFAULT NULL,
        `buyerName` VARCHAR(100) DEFAULT NULL,
        `buyerPhone` VARCHAR(30) DEFAULT NULL,
        `buyerEmail` VARCHAR(120) DEFAULT NULL,
        `amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        `method` VARCHAR(50) DEFAULT 'Razorpay UPI',
        `status` VARCHAR(30) DEFAULT 'completed',
        `date` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;",

    // 5. Notifications Table
    "CREATE TABLE IF NOT EXISTS `notifications` (
        `id` VARCHAR(64) PRIMARY KEY,
        `type` VARCHAR(50) DEFAULT 'system',
        `title` VARCHAR(500) NOT NULL,
        `message` TEXT NOT NULL,
        `propertyId` VARCHAR(64) DEFAULT NULL,
        `propertyTitle` VARCHAR(500) DEFAULT NULL,
        `sellerName` VARCHAR(100) DEFAULT NULL,
        `sellerPhone` VARCHAR(30) DEFAULT NULL,
        `price` DECIMAL(14,2) DEFAULT NULL,
        `propertyType` VARCHAR(50) DEFAULT NULL,
        `location` VARCHAR(200) DEFAULT NULL,
        `isRead` TINYINT(1) DEFAULT 0,
        `status` VARCHAR(30) DEFAULT 'pending',
        `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;",

    // 6. User Activities & Leads Table
    "CREATE TABLE IF NOT EXISTS `user_activities` (
        `id` VARCHAR(64) PRIMARY KEY,
        `user_id` VARCHAR(64) DEFAULT NULL,
        `user_name` VARCHAR(100) NOT NULL,
        `user_phone` VARCHAR(30) DEFAULT NULL,
        `user_email` VARCHAR(120) DEFAULT NULL,
        `action_type` VARCHAR(50) NOT NULL,
        `action_title` VARCHAR(200) DEFAULT NULL,
        `property_id` VARCHAR(64) DEFAULT NULL,
        `property_title` VARCHAR(500) DEFAULT NULL,
        `property_type` VARCHAR(50) DEFAULT NULL,
        `property_location` VARCHAR(200) DEFAULT NULL,
        `seller_id` VARCHAR(64) DEFAULT NULL,
        `seller_name` VARCHAR(100) DEFAULT NULL,
        `seller_phone` VARCHAR(30) DEFAULT NULL,
        `amount` DECIMAL(10,2) DEFAULT 0.00,
        `details` TEXT DEFAULT NULL,
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;",

    // 7. Legal Inquiries Table
    "CREATE TABLE IF NOT EXISTS `legal_inquiries` (
        `id` VARCHAR(64) PRIMARY KEY,
        `name` VARCHAR(100) NOT NULL,
        `phone` VARCHAR(30) NOT NULL,
        `location` VARCHAR(150) NOT NULL,
        `service_type` VARCHAR(100) NOT NULL,
        `notes` TEXT,
        `status` VARCHAR(30) DEFAULT 'pending',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"
];

$executed = 0;
$errors = [];
foreach ($queries as $q) {
    try {
        $pdo->exec($q);
        $executed++;
    } catch (Exception $e) {
        $errors[] = $e->getMessage();
    }
}

// ---- SEED PROPERTIES FROM properties.json INTO DB ----
$stmt = $pdo->query("SELECT COUNT(*) FROM `properties`");
$propCount = (int)$stmt->fetchColumn();

$seeded = 0;
if (isset($_GET['seed']) && $_GET['seed'] === 'true' && $propCount === 0) {
    $jsonProps = readJsonStorage('properties.json');
    if (!empty($jsonProps)) {
        $insertSql = "INSERT INTO `properties` 
            (`id`, `title`, `description`, `price`, `location`, `city`, `propertyType`, `areaSqFt`, `superBuiltUpSqFt`, `carpetAreaSqFt`, `bedrooms`, `bathrooms`, `furnishingStatus`, `facing`, `floor`, `maintenanceMonthly`, `landmark`, `posterType`, `landUnit`, `landUnitValue`, `landFeatures`, `approvalType`, `isBankLoanAvailable`, `isPriceNegotiable`, `waterSource`, `hasLift`, `hasTrees`, `treesDetails`, `hasIncome`, `incomeDetails`, `isLease`, `rentalSubType`, `advanceAmount`, `commercialAreaType`, `hasTable`, `hasFan`, `hasWaterSupply`, `hasShutter`, `powerPhase`, `contactPhone`, `sellerName`, `sellerPhone`, `imageKeys`, `imageUrls`, `amenities`, `agent_id`, `agent_name`, `agent_agencyName`, `agent_phone`, `agent_email`, `postedDate`, `status`, `isFavorite`, `isVerified`, `isFeatured`, `isUserPosted`, `views`, `enquiries`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE `title` = VALUES(`title`)";
        $insertStmt = $pdo->prepare($insertSql);

        foreach ($jsonProps as $p) {
            $agent = $p['agent'] ?? [];
            try {
                $insertStmt->execute([
                    $p['id'] ?? uniqid('prop_'),
                    $p['title'] ?? '',
                    $p['description'] ?? '',
                    $p['price'] ?? 0,
                    $p['location'] ?? 'Tenkasi',
                    $p['city'] ?? 'Tenkasi',
                    $p['propertyType'] ?? 'Land',
                    $p['areaSqFt'] ?? 0,
                    $p['superBuiltUpSqFt'] ?? null,
                    $p['carpetAreaSqFt'] ?? null,
                    $p['bedrooms'] ?? null,
                    $p['bathrooms'] ?? null,
                    $p['furnishingStatus'] ?? 'Unfurnished',
                    $p['facing'] ?? 'East',
                    $p['floor'] ?? 'Ground Floor',
                    $p['maintenanceMonthly'] ?? null,
                    $p['landmark'] ?? null,
                    $p['posterType'] ?? 'Direct Owner',
                    $p['landUnit'] ?? null,
                    $p['landUnitValue'] ?? null,
                    json_encode($p['landFeatures'] ?? [], JSON_UNESCAPED_UNICODE),
                    $p['approvalType'] ?? null,
                    !empty($p['isBankLoanAvailable']) ? 1 : 0,
                    isset($p['isPriceNegotiable']) ? ($p['isPriceNegotiable'] ? 1 : 0) : 1,
                    $p['waterSource'] ?? 'Both',
                    !empty($p['hasLift']) ? 1 : 0,
                    !empty($p['hasTrees']) ? 1 : 0,
                    $p['treesDetails'] ?? null,
                    !empty($p['hasIncome']) ? 1 : 0,
                    $p['incomeDetails'] ?? null,
                    !empty($p['isLease']) ? 1 : 0,
                    $p['rentalSubType'] ?? null,
                    $p['advanceAmount'] ?? null,
                    $p['commercialAreaType'] ?? null,
                    !empty($p['hasTable']) ? 1 : 0,
                    !empty($p['hasFan']) ? 1 : 0,
                    !empty($p['hasWaterSupply']) ? 1 : 0,
                    !empty($p['hasShutter']) ? 1 : 0,
                    $p['powerPhase'] ?? null,
                    $p['contactPhone'] ?? '+91 98941 74944',
                    $p['sellerName'] ?? 'Direct Owner',
                    $p['sellerPhone'] ?? '+91 98941 74944',
                    json_encode($p['imageKeys'] ?? [], JSON_UNESCAPED_UNICODE),
                    json_encode($p['imageUrls'] ?? [], JSON_UNESCAPED_UNICODE),
                    json_encode($p['amenities'] ?? [], JSON_UNESCAPED_UNICODE),
                    $agent['id'] ?? 'admin_agent',
                    $agent['name'] ?? $p['sellerName'] ?? 'Direct Owner',
                    $agent['agencyName'] ?? 'நேரடி உரிமையாளர் (Direct Owner)',
                    $agent['phone'] ?? $p['sellerPhone'] ?? '+91 98941 74944',
                    $agent['email'] ?? 'tenkasidreams@gmail.com',
                    $p['postedDate'] ?? date('Y-m-d H:i:s'),
                    $p['status'] ?? 'active',
                    !empty($p['isFavorite']) ? 1 : 0,
                    isset($p['isVerified']) ? ($p['isVerified'] ? 1 : 0) : 1,
                    !empty($p['isFeatured']) ? 1 : 0,
                    !empty($p['isUserPosted']) ? 1 : 0,
                    $p['views'] ?? 0,
                    $p['enquiries'] ?? 0
                ]);
                $seeded++;
            } catch (Exception $e) {
                $errors[] = 'Seed error [' . ($p['id'] ?? '?') . ']: ' . $e->getMessage();
            }
        }
    }
    $propCount = $seeded;
}

// ---- SEED BUYER REQUIREMENTS ----
$stmt2 = $pdo->query("SELECT COUNT(*) FROM `buyer_requirements`");
$reqCount = (int)$stmt2->fetchColumn();
$reqSeeded = 0;
if ($reqCount === 0) {
    $jsonReqs = readJsonStorage('requirements.json');
    if (!empty($jsonReqs)) {
        $reqStmt = $pdo->prepare("INSERT INTO `buyer_requirements` 
            (`id`, `userName`, `userPhone`, `propertyType`, `targetLocation`, `budgetMin`, `budgetMax`, `preferredSize`, `facingPreference`, `description`, `status`, `postedDate`)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE `userName` = VALUES(`userName`)");
        foreach ($jsonReqs as $r) {
            try {
                $reqStmt->execute([
                    $r['id'] ?? uniqid('req_'),
                    $r['userName'] ?? '',
                    $r['userPhone'] ?? '',
                    $r['propertyType'] ?? 'Land',
                    $r['targetLocation'] ?? 'Tenkasi',
                    $r['budgetMin'] ?? null,
                    $r['budgetMax'] ?? null,
                    $r['preferredSize'] ?? null,
                    $r['facingPreference'] ?? null,
                    $r['description'] ?? '',
                    $r['status'] ?? 'active',
                    $r['postedDate'] ?? date('Y-m-d H:i:s')
                ]);
                $reqSeeded++;
            } catch (Exception $e) {
                $errors[] = 'Req seed error: ' . $e->getMessage();
            }
        }
    }
}

echo json_encode([
    'success' => true,
    'message' => '✅ MySQL Database tables created & seeded successfully!',
    'database' => DB_NAME,
    'host' => DB_HOST,
    'user' => DB_USER,
    'tables_executed' => $executed,
    'properties_in_db' => $propCount,
    'properties_seeded' => $seeded,
    'requirements_seeded' => $reqSeeded,
    'errors' => $errors
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
