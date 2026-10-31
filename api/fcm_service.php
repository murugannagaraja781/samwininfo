<?php
/**
 * Firebase Cloud Messaging (FCM HTTP v1) Service
 * Sends high-priority push notifications with loud alarm sound to Super Admin
 */

function base64UrlEncode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

/**
 * Get Google OAuth2 Access Token using Service Account JWT
 */
function getGoogleAccessToken() {
    $cacheFile = __DIR__ . '/data/fcm_token_cache.json';
    
    // Check cached token
    if (file_exists($cacheFile)) {
        $cached = json_decode(file_get_contents($cacheFile), true);
        if ($cached && isset($cached['access_token']) && isset($cached['expires_at'])) {
            if ($cached['expires_at'] > time() + 120) {
                return $cached['access_token'];
            }
        }
    }

    $saPath = __DIR__ . '/service-account.json';
    if (!file_exists($saPath)) {
        error_log('FCM Error: service-account.json not found');
        return null;
    }

    $sa = json_decode(file_get_contents($saPath), true);
    if (!$sa || empty($sa['private_key']) || empty($sa['client_email'])) {
        error_log('FCM Error: Invalid service-account.json');
        return null;
    }

    $now = time();
    $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
    $claimSet = json_encode([
        'iss' => $sa['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => 'https://oauth2.googleapis.com/token',
        'exp' => $now + 3600,
        'iat' => $now
    ]);

    $encodedHeader = base64UrlEncode($header);
    $encodedClaim = base64UrlEncode($claimSet);
    $signatureInput = $encodedHeader . '.' . $encodedClaim;

    $signature = '';
    $privateKey = openssl_pkey_get_private($sa['private_key']);
    if (!$privateKey) {
        error_log('FCM Error: Invalid private key in service-account.json');
        return null;
    }

    $signed = openssl_sign($signatureInput, $signature, $privateKey, OPENSSL_ALGO_SHA256);
    if (!$signed) {
        error_log('FCM Error: Failed to sign JWT');
        return null;
    }

    $encodedSignature = base64UrlEncode($signature);
    $jwt = $signatureInput . '.' . $encodedSignature;

    // Exchange JWT for Access Token
    $ch = curl_init('https://oauth2.googleapis.com/token');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt
        ]),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_SSL_VERIFYPEER => false
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode !== 200) {
        error_log("FCM Error: Token request failed with HTTP $httpCode: $response");
        return null;
    }

    $data = json_decode($response, true);
    if (!isset($data['access_token'])) {
        return null;
    }

    // Cache token
    $cacheData = [
        'access_token' => $data['access_token'],
        'expires_at' => $now + ($data['expires_in'] ?? 3600)
    ];
    @file_put_contents($cacheFile, json_encode($cacheData));

    return $data['access_token'];
}

/**
 * Send FCM HTTP v1 Notification
 */
function sendFcmNotification($target, $title, $body, $data = [], $isTopic = true) {
    $accessToken = getGoogleAccessToken();
    if (!$accessToken) {
        error_log('FCM Error: Could not obtain Google Access Token');
        return false;
    }

    $projectId = 'tenkasi-dreams';
    $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

    // Ensure all data values are strings (required by FCM HTTP v1)
    $stringData = [];
    foreach ($data as $k => $v) {
        $stringData[(string)$k] = is_scalar($v) ? (string)$v : json_encode($v, JSON_UNESCAPED_UNICODE);
    }
    $stringData['sound'] = 'alarm';
    $stringData['channel_id'] = 'admin_ad_alert_channel';

    $message = [
        'notification' => [
            'title' => $title,
            'body' => $body
        ],
        'android' => [
            'priority' => 'HIGH',
            'notification' => [
                'channel_id' => 'admin_ad_alert_channel',
                'sound' => 'alarm',
                'default_sound' => false,
                'notification_priority' => 'PRIORITY_MAX',
                'visibility' => 'PUBLIC',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
            ]
        ],
        'data' => $stringData
    ];

    if ($isTopic) {
        $message['topic'] = $target;
    } else {
        $message['token'] = $target;
    }

    $payload = json_encode(['message' => $message], JSON_UNESCAPED_UNICODE);

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $payload,
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $accessToken,
            'Content-Type: application/json; UTF-8'
        ],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_SSL_VERIFYPEER => false
    ]);

    $result = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode === 200) {
        return json_decode($result, true);
    } else {
        error_log("FCM Send Error (HTTP $httpCode): $result");
        return false;
    }
}

/**
 * Trigger high-priority Super Admin alert when a user submits a new property ad
 */
function sendAdminNewAdNotification($property) {
    $title = '🔔 புதிய விளம்பரம் அப்ரூவலுக்கு வந்துள்ளது!';
    $sellerName = $property['sellerName'] ?? $property['contactPhone'] ?? 'பயனர்';
    $sellerPhone = $property['sellerPhone'] ?? $property['contactPhone'] ?? '';
    $adTitle = $property['title'] ?? 'புதிய விளம்பரம்';
    $price = isset($property['price']) ? '₹' . number_format((float)$property['price']) : '';

    $body = "{$sellerName} ({$sellerPhone}) என்பவர் '{$adTitle}' ({$price}) என்ற புதிய விளம்பரத்தை பதிவிட்டுள்ளார். உடனே சரிபார்க்கவும்!";

    $data = [
        'type' => 'new_property_ad',
        'property_id' => (string)($property['id'] ?? ''),
        'property_title' => (string)$adTitle,
        'seller_name' => (string)$sellerName,
        'seller_phone' => (string)$sellerPhone,
        'price' => (string)($property['price'] ?? 0),
        'location' => (string)($property['location'] ?? ''),
        'property_type' => (string)($property['propertyType'] ?? '')
    ];

    // 1. Send to topic 'admin_new_ads'
    $res = sendFcmNotification('admin_new_ads', $title, $body, $data, true);

    // 2. Also send to specific admin registered tokens if any
    $tokensFile = __DIR__ . '/data/admin_fcm_tokens.json';
    if (file_exists($tokensFile)) {
        $tokens = json_decode(file_get_contents($tokensFile), true) ?: [];
        foreach ($tokens as $token) {
            if (!empty($token)) {
                sendFcmNotification($token, $title, $body, $data, false);
            }
        }
    }

    return $res;
}
