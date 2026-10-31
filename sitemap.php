<?php
/**
 * Dynamic XML Sitemap Generator
 * Conforms 100% to Google Sitemap Protocol 0.9 & Image Sitemap Schema 1.1
 * Automatically includes every new product/property added to the database or JSON.
 */

require_once __DIR__ . '/api/config.php';

function buildSitemapXml($saveToDisk = false) {
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'ads.mithradigitalsolutions.com';
    $baseUrl = (defined('APP_URL') && !empty(APP_URL) && !str_contains(APP_URL, 'localhost')) 
        ? rtrim(APP_URL, '/') 
        : ($protocol . '://' . $host);

    // Fetch all active properties from Database (with JSON fallback)
    $pdo = getDbConnection();
    $properties = [];

    if ($pdo) {
        try {
            $stmt = $pdo->query("SELECT `id`, `title`, `description`, `price`, `location`, `city`, `propertyType`, `imageUrls`, `postedDate`, `created_at`, `updated_at` FROM `properties` WHERE `status` = 'active' ORDER BY `updated_at` DESC, `created_at` DESC");
            $properties = $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            $properties = [];
        }
    }

    if (empty($properties)) {
        $jsonProps = readJsonStorage('properties.json');
        foreach ($jsonProps as $p) {
            if (($p['status'] ?? 'active') === 'active') {
                $properties[] = $p;
            }
        }
    }

    $nowIso = date('Y-m-d\TH:i:sP');

    $xml = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    $xml .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"' . "\n";
    $xml .= '        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"' . "\n";
    $xml .= '        xmlns:xhtml="http://www.w3.org/1999/xhtml">' . "\n\n";

    // 1. Homepage (Highest Priority)
    $xml .= "  <!-- Core Portal Homepage -->\n";
    $xml .= "  <url>\n";
    $xml .= "    <loc>" . htmlspecialchars($baseUrl . '/', ENT_XML1, 'UTF-8') . "</loc>\n";
    $xml .= "    <lastmod>" . $nowIso . "</lastmod>\n";
    $xml .= "    <changefreq>always</changefreq>\n";
    $xml .= "    <priority>1.0</priority>\n";
    $xml .= "  </url>\n\n";

    // 2. Real Estate Category Hubs (for targeted keyword search)
    $categories = [
        'house'     => ['name' => 'House / Villa (தனி வீடு / வில்லா)',      'priority' => '0.9'],
        'land'      => ['name' => 'Plots & Land (வீட்டு மனை / நிலம்)',     'priority' => '0.9'],
        'farm'      => ['name' => 'Farmland (விவசாய தோட்டம் & பண்ணை)',      'priority' => '0.9'],
        'commercial'=> ['name' => 'Commercial & Shop (வணிக வளாகம் & கடை)',  'priority' => '0.85'],
        'rental'    => ['name' => 'Rental & Lease (வாடகை வீடு / லீஸ்)',    'priority' => '0.85'],
        'apartment' => ['name' => 'Apartments & Flats (அடுக்குமாடி குடியிருப்பு)', 'priority' => '0.85'],
    ];

    $xml .= "  <!-- Main Property Category Hubs -->\n";
    foreach ($categories as $catKey => $catInfo) {
        $xml .= "  <url>\n";
        $xml .= "    <loc>" . htmlspecialchars($baseUrl . '/?category=' . $catKey, ENT_XML1, 'UTF-8') . "</loc>\n";
        $xml .= "    <lastmod>" . $nowIso . "</lastmod>\n";
        $xml .= "    <changefreq>daily</changefreq>\n";
        $xml .= "    <priority>" . $catInfo['priority'] . "</priority>\n";
        $xml .= "  </url>\n";
    }
    $xml .= "\n";

    // 3. Static Trust & Policy Pages
    $staticPages = [
        ['file' => 'privacy.html', 'priority' => '0.3', 'freq' => 'monthly'],
        ['file' => 'terms.html',   'priority' => '0.3', 'freq' => 'monthly'],
        ['file' => 'refund.html',  'priority' => '0.3', 'freq' => 'monthly'],
    ];

    $xml .= "  <!-- Policy and Information Pages -->\n";
    foreach ($staticPages as $sp) {
        $filePath = __DIR__ . '/' . $sp['file'];
        $mtime = file_exists($filePath) ? filemtime($filePath) : strtotime('-1 week');
        $xml .= "  <url>\n";
        $xml .= "    <loc>" . htmlspecialchars($baseUrl . '/' . $sp['file'], ENT_XML1, 'UTF-8') . "</loc>\n";
        $xml .= "    <lastmod>" . date('Y-m-d\TH:i:sP', $mtime) . "</lastmod>\n";
        $xml .= "    <changefreq>" . $sp['freq'] . "</changefreq>\n";
        $xml .= "    <priority>" . $sp['priority'] . "</priority>\n";
        $xml .= "  </url>\n";
    }
    $xml .= "\n";

    // 4. Dynamic Properties / Products Listings (Each ad has its own unique, indexable URL with Google Images)
    $xml .= "  <!-- Dynamic Product & Property Ads Listings (" . count($properties) . " Items) -->\n";
    foreach ($properties as $p) {
        $propId = trim($p['id'] ?? '');
        if (empty($propId)) continue;

        $dateStr = !empty($p['updated_at']) ? $p['updated_at'] : (!empty($p['created_at']) ? $p['created_at'] : (!empty($p['postedDate']) ? $p['postedDate'] : null));
        $timestamp = $dateStr ? strtotime($dateStr) : time();
        $propLastMod = date('Y-m-d\TH:i:sP', $timestamp > 0 ? $timestamp : time());

        $propUrl = $baseUrl . '/?id=' . rawurlencode($propId);

        $xml .= "  <url>\n";
        $xml .= "    <loc>" . htmlspecialchars($propUrl, ENT_XML1, 'UTF-8') . "</loc>\n";
        $xml .= "    <lastmod>" . $propLastMod . "</lastmod>\n";
        $xml .= "    <changefreq>daily</changefreq>\n";
        $xml .= "    <priority>0.80</priority>\n";

        // Extract Property Photos for Google Images SEO
        $images = [];
        if (!empty($p['imageUrls'])) {
            $decoded = is_array($p['imageUrls']) ? $p['imageUrls'] : json_decode($p['imageUrls'], true);
            if (is_array($decoded)) {
                $images = $decoded;
            }
        }

        $titleClean = trim(strip_tags($p['title'] ?? 'Real Estate Property'));
        $price = !empty($p['price']) ? '₹ ' . number_format((float)$p['price']) : '';
        $loc = trim($p['location'] ?? $p['city'] ?? 'Tenkasi');
        $captionClean = trim("$titleClean | $price | $loc");

        foreach ($images as $img) {
            if (empty($img) || !is_string($img) || str_starts_with($img, 'data:')) continue;
            
            // Format absolute URL
            $imgAbs = $img;
            if (!str_starts_with($imgAbs, 'http://') && !str_starts_with($imgAbs, 'https://')) {
                $imgAbs = $baseUrl . '/' . ltrim($imgAbs, '/');
            }

            $xml .= "    <image:image>\n";
            $xml .= "      <image:loc>" . htmlspecialchars($imgAbs, ENT_XML1, 'UTF-8') . "</image:loc>\n";
            $xml .= "      <image:title>" . htmlspecialchars($titleClean, ENT_XML1, 'UTF-8') . "</image:title>\n";
            $xml .= "      <image:caption>" . htmlspecialchars($captionClean, ENT_XML1, 'UTF-8') . "</image:caption>\n";
            $xml .= "    </image:image>\n";
        }

        $xml .= "  </url>\n";
    }

    $xml .= "</urlset>\n";

    if ($saveToDisk) {
        @file_put_contents(__DIR__ . '/sitemap.xml', $xml);
    }

    return $xml;
}

// If invoked directly from web request
if (basename(__FILE__) === basename($_SERVER['SCRIPT_FILENAME'] ?? '')) {
    header('Content-Type: application/xml; charset=utf-8');
    header('Cache-Control: public, max-age=1800'); // 30 minutes cache for bots
    header('X-Robots-Tag: noindex, follow'); // Sitemap itself shouldn't show in SERP text, but followed

    // Generate XML and write copy to disk
    $xmlContent = buildSitemapXml(true);
    echo $xmlContent;
    exit();
}
