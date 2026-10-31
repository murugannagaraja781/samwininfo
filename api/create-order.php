<?php
require_once __DIR__ . '/config.php';

// Ensure POST request
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    sendResponse(['success' => false, 'error' => 'Method not allowed. Only POST is accepted.'], 405);
}

// Parse JSON or form POST input
$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true);
if (!is_array($input)) {
    $input = $_POST;
}

// Validate amount (in paise, minimum 100 paise = ₹1.00)
$amount = isset($input['amount']) ? (int)$input['amount'] : 0;
// If amount is passed in Rupees (e.g. 10 or 30), convert to paise (10 * 100 = 1000 paise)
if ($amount > 0 && $amount < 100) {
    $amount = $amount * 100;
}
if ($amount < 100) {
    sendResponse([
        'success' => false,
        'error' => 'Invalid amount. Minimum amount is 100 paise (₹1.00).'
    ], 400);
}

$currency = !empty($input['currency']) ? strtoupper(trim($input['currency'])) : 'INR';
$receipt = !empty($input['receipt']) ? trim($input['receipt']) : ('rcpt_' . time() . '_' . rand(100, 999));
$notes = isset($input['notes']) && is_array($input['notes']) ? $input['notes'] : [];

$payload = [
    'amount' => $amount,
    'currency' => $currency,
    'receipt' => $receipt,
    'notes' => $notes
];

// Call Razorpay Orders API
$ch = curl_init('https://api.razorpay.com/v1/orders');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_USERPWD, RAZORPAY_KEY_ID . ':' . RAZORPAY_KEY_SECRET);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_TIMEOUT, 15);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
curl_close($ch);

if ($response === false) {
    sendResponse([
        'success' => false,
        'error' => 'cURL error connecting to Razorpay: ' . $curlError
    ], 500);
}

$result = json_decode($response, true);

// Handle Razorpay Authentication Failure
if ($httpCode === 401) {
    sendResponse([
        'success' => false,
        'error' => 'Razorpay authentication failed: Invalid Key ID or Key Secret.'
    ], 401);
}

// Handle Razorpay API Errors
if ($httpCode < 200 || $httpCode >= 300 || empty($result['id'])) {
    $errorMessage = $result['error']['description'] ?? $result['error']['message'] ?? 'Razorpay API error creating order.';
    sendResponse([
        'success' => false,
        'error' => $errorMessage,
        'razorpay_error' => $result['error'] ?? null
    ], 500);
}

// Successful order creation
sendResponse([
    'success' => true,
    'order_id' => $result['id'],
    'amount' => $result['amount'],
    'currency' => $result['currency'],
    'key_id' => RAZORPAY_KEY_ID,
    'mode' => RAZORPAY_MODE
], 200);
