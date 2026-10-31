<?php
// Public Front Page, SEO Metadata Engine & Policy Router for Ads
require_once __DIR__ . '/api/config.php';
header('Content-Type: text/html; charset=UTF-8');

$page = strtolower(trim($_GET['page'] ?? ''));

// 1. Direct Sitemap Route
if ($page === 'sitemap' || $page === 'sitemap.xml') {
    require_once __DIR__ . '/sitemap.php';
    exit();
}

if ($page === 'debug_diag') {
    header('Content-Type: application/json');
    echo json_encode([
        'dir' => __DIR__,
        'file' => __FILE__,
        'server_time' => date('Y-m-d H:i:s'),
        'php_version' => PHP_VERSION,
        'doc_root' => $_SERVER['DOCUMENT_ROOT'] ?? '',
        'script_filename' => $_SERVER['SCRIPT_FILENAME'] ?? ''
    ]);
    exit();
}

if ($page === 'privacy' || $page === 'privacy-policy') {
    require_once __DIR__ . '/privacy.html';
    exit();
}

if ($page === 'terms' || $page === 'terms-conditions' || $page === 'terms-and-conditions') {
    require_once __DIR__ . '/terms.html';
    exit();
}

if ($page === 'refund' || $page === 'refund-policy' || $page === 'cancellation') {
    require_once __DIR__ . '/refund.html';
    exit();
}

// 2. Dynamic SEO Metadata & Schema.org Structured Data Engine
$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'ads.mithradigitalsolutions.com';
$baseUrl = (defined('APP_URL') && !empty(APP_URL) && !str_contains(APP_URL, 'localhost')) 
    ? rtrim(APP_URL, '/') 
    : ($protocol . '://' . $host);

$propId = trim($_GET['id'] ?? $_GET['prop_id'] ?? '');
$categoryParam = strtolower(trim($_GET['category'] ?? ''));

// Default Branding
$siteName = defined('APP_NAME') ? APP_NAME : 'Ads';
$defaultTitle = $siteName . ' - ரியல் எஸ்டேட் & விளம்பரங்கள் | Mithra Digital Solutions';
$defaultDesc = 'நிலம், மனை, தனி வீடு, தோட்டம், கடை வாங்க விற்க சிறந்த விளம்பரத் தளம். 100% சரிபார்க்கப்பட்ட சொத்துக்கள்.';
$defaultImage = $baseUrl . '/assets/images/app_logo.png';
$canonicalUrl = $baseUrl . '/';

$seoTitle = $defaultTitle;
$seoDesc = $defaultDesc;
$seoImage = $defaultImage;
$ogType = 'website';
$jsonLdSchemas = [];

// Website & Sitelinks SearchBox Schema for Google
$jsonLdSchemas[] = [
    '@context' => 'https://schema.org',
    '@type' => 'WebSite',
    'name' => $siteName,
    'alternateName' => 'Mithra Digital Solutions Ads',
    'url' => $baseUrl . '/',
    'potentialAction' => [
        '@type' => 'SearchAction',
        'target' => [
            '@type' => 'EntryPoint',
            'urlTemplate' => $baseUrl . '/?q={search_term_string}'
        ],
        'query-input' => 'required name=search_term_string'
    ]
];

// Organization / Real Estate Business Schema
$jsonLdSchemas[] = [
    '@context' => 'https://schema.org',
    '@type' => 'RealEstateAgent',
    'name' => $siteName . ' Real Estate Portal',
    'image' => $defaultImage,
    'url' => $baseUrl,
    'telephone' => defined('ADMIN_PHONE') ? ADMIN_PHONE : '+91 98941 74944',
    'email' => defined('ADMIN_EMAIL') ? ADMIN_EMAIL : 'tenkasidreams@gmail.com',
    'address' => [
        '@type' => 'PostalAddress',
        'addressLocality' => 'Tenkasi',
        'addressRegion' => 'Tamil Nadu',
        'addressCountry' => 'IN'
    ],
    'priceRange' => '₹₹ - ₹₹₹₹'
];

if (!empty($propId)) {
    // Look up property in DB (or JSON fallback)
    $propData = null;
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->prepare("SELECT * FROM `properties` WHERE `id` = ? LIMIT 1");
            $stmt->execute([$propId]);
            $propData = $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (Exception $e) {}
    }

    if (!$propData) {
        $jsonProps = readJsonStorage('properties.json');
        foreach ($jsonProps as $p) {
            if (($p['id'] ?? '') === $propId) {
                $propData = $p;
                break;
            }
        }
    }

    if ($propData) {
        $cleanTitle = htmlspecialchars(trim($propData['title'] ?? 'Real Estate Property'), ENT_QUOTES, 'UTF-8');
        $location = htmlspecialchars(trim($propData['location'] ?? 'Tenkasi'), ENT_QUOTES, 'UTF-8');
        $propType = htmlspecialchars(trim($propData['propertyType'] ?? 'Land'), ENT_QUOTES, 'UTF-8');
        $price = (float)($propData['price'] ?? 0);
        $priceFormatted = $price > 0 ? ('₹ ' . number_format($price)) : 'விலை பேசித் தீர்மானிக்கலாம்';

        $seoTitle = "{$cleanTitle} - {$priceFormatted} | {$siteName}";
        
        $descRaw = trim(strip_tags($propData['description'] ?? ''));
        if (empty($descRaw)) {
            $descRaw = "{$cleanTitle} located at {$location}. {$propType} for immediate sale / rent with verified documents.";
        }
        $seoDesc = mb_substr($descRaw, 0, 160) . '...';
        
        $canonicalUrl = $baseUrl . '/?id=' . rawurlencode($propId);
        $ogType = 'article';

        // Extract photos
        $images = [];
        if (!empty($propData['imageUrls'])) {
            $decoded = is_array($propData['imageUrls']) ? $propData['imageUrls'] : json_decode($propData['imageUrls'], true);
            if (is_array($decoded)) {
                $images = $decoded;
            }
        }
        if (!empty($images) && is_string($images[0]) && !str_starts_with($images[0], 'data:')) {
            $firstImg = $images[0];
            $seoImage = str_starts_with($firstImg, 'http') ? $firstImg : ($baseUrl . '/' . ltrim($firstImg, '/'));
        }

        // Schema.org RealEstateListing + Product Schema for Google Rich Snippets
        $jsonLdSchemas[] = [
            '@context' => 'https://schema.org',
            '@type' => 'Product',
            'name' => $cleanTitle,
            'image' => array_values(array_filter($images, fn($u) => is_string($u) && !str_starts_with($u, 'data:'))),
            'description' => $seoDesc,
            'category' => $propType,
            'offers' => [
                '@type' => 'Offer',
                'price' => (string)$price,
                'priceCurrency' => 'INR',
                'priceValidUntil' => date('Y-m-d', strtotime('+1 year')),
                'availability' => 'https://schema.org/InStock',
                'url' => $canonicalUrl,
                'seller' => [
                    '@type' => 'Person',
                    'name' => $propData['sellerName'] ?? 'Direct Owner',
                    'telephone' => $propData['sellerPhone'] ?? '+919894174944'
                ]
            ]
        ];

        $jsonLdSchemas[] = [
            '@context' => 'https://schema.org',
            '@type' => 'RealEstateListing',
            'name' => $cleanTitle,
            'description' => $seoDesc,
            'url' => $canonicalUrl,
            'datePosted' => date('c', !empty($propData['created_at']) ? strtotime($propData['created_at']) : time()),
            'category' => $propType,
            'contentLocation' => [
                '@type' => 'Place',
                'name' => $location,
                'address' => [
                    '@type' => 'PostalAddress',
                    'addressLocality' => $propData['city'] ?? 'Tenkasi',
                    'addressRegion' => 'Tamil Nadu',
                    'addressCountry' => 'IN'
                ]
            ]
        ];
    }
} elseif (!empty($categoryParam)) {
    $categoryNames = [
        'house' => 'Houses & Individual Villas (தனி வீடுகள்)',
        'land' => 'Land & Plots (வீட்டு மனைகள் & இடங்கள்)',
        'farm' => 'Farmland & Agri Properties (விவசாய நிலங்கள் & தோட்டங்கள்)',
        'commercial' => 'Commercial Shops & Buildings (வணிக கடைகள்)',
        'rental' => 'Rental & Lease Homes (வாடகை வீடுகள்)',
        'apartment' => 'Apartments & Flats (அடுக்குமாடி குடியிருப்புகள்)',
    ];
    $catDisplayName = $categoryNames[$categoryParam] ?? ucfirst($categoryParam);
    $seoTitle = "{$catDisplayName} in Tenkasi | {$siteName}";
    $seoDesc = "Explore top verified {$catDisplayName} for sale and rent in Tenkasi and surrounding areas on {$siteName}.";
    $canonicalUrl = $baseUrl . '/?category=' . rawurlencode($categoryParam);
}

// 3. Render HTML with Injected High-Performance SEO Elements
$html = file_get_contents(__DIR__ . '/index.html');

// Build JSON-LD Scripts Block
$schemaScripts = '';
foreach ($jsonLdSchemas as $schema) {
    $schemaScripts .= "\n  <script type=\"application/ld+json\">\n" . json_encode($schema, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . "\n  </script>";
}

// Open Graph & Twitter Cards Block
$metaTags = <<<HTML
  <!-- 100% Automated SEO Meta Tags -->
  <link rel="canonical" href="{$canonicalUrl}">
  <link rel="sitemap" type="application/xml" title="Sitemap" href="{$baseUrl}/sitemap.xml">

  <!-- Open Graph / Facebook / WhatsApp Preview -->
  <meta property="og:type" content="{$ogType}">
  <meta property="og:site_name" content="{$siteName}">
  <meta property="og:url" content="{$canonicalUrl}">
  <meta property="og:title" content="{$seoTitle}">
  <meta property="og:description" content="{$seoDesc}">
  <meta property="og:image" content="{$seoImage}">
  <meta property="og:image:alt" content="{$seoTitle}">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:url" content="{$canonicalUrl}">
  <meta name="twitter:title" content="{$seoTitle}">
  <meta name="twitter:description" content="{$seoDesc}">
  <meta name="twitter:image" content="{$seoImage}">
  {$schemaScripts}
HTML;

// Replace title & description in index.html
$html = preg_replace('/<title>.*?<\/title>/is', '<title>' . htmlspecialchars($seoTitle, ENT_QUOTES, 'UTF-8') . '</title>', $html, 1);
$html = preg_replace('/<meta name="description" content=".*?"\/?>/is', '<meta name="description" content="' . htmlspecialchars($seoDesc, ENT_QUOTES, 'UTF-8') . '">', $html, 1);

// Inject meta tags before </head>
$html = str_replace('</head>', $metaTags . "\n</head>", $html);

echo $html;
