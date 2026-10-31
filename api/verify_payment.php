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

// Check required fields
$orderId = trim($input['razorpay_order_id'] ?? '');
$paymentId = trim($input['razorpay_payment_id'] ?? '');
$signature = trim($input['razorpay_signature'] ?? '');

if (empty($orderId) || empty($paymentId) || empty($signature)) {
    sendResponse([
        'success' => false,
        'error' => 'Missing required payment verification fields (razorpay_order_id, razorpay_payment_id, razorpay_signature).'
    ], 400);
}

// Verify Signature: HMAC-SHA256(order_id + "|" + payment_id, KEY_SECRET)
$expectedSignature = hash_hmac('sha256', $orderId . '|' . $paymentId, RAZORPAY_KEY_SECRET);

if (!hash_equals($expectedSignature, $signature)) {
    sendResponse([
        'success' => false,
        'error' => 'Payment signature verification failed. The transaction may be tampered or invalid.'
    ], 400);
}

// Signature matches! Record payment and unlock contact
$paymentsFile = DATA_DIR . '/payments.json';
$paymentsData = [
    'stats' => ['totalRevenue' => 0, 'paidUnlocksCount' => 0, 'freeViewsCount' => 0],
    'payments' => []
];

if (file_exists($paymentsFile)) {
    $raw = file_get_contents($paymentsFile);
    $decoded = json_decode($raw, true);
    if (is_array($decoded)) {
        $paymentsData = $decoded;
    }
}
if (!isset($paymentsData['stats'])) {
    $paymentsData['stats'] = ['totalRevenue' => 0, 'paidUnlocksCount' => 0, 'freeViewsCount' => 0];
}
if (!isset($paymentsData['payments'])) {
    $paymentsData['payments'] = [];
}

// Calculate amount
$amount = (int)($input['amount'] ?? (OFFER_ACTIVE ? OFFER_UNLOCK_PRICE : CONTACT_UNLOCK_PRICE));
if ($amount >= 100 && isset($input['amount_in_paise']) && $input['amount_in_paise']) {
    $amount = (int)round($amount / 100);
}

$propId = trim($input['propId'] ?? $input['property_id'] ?? 'unknown');
$propTitle = trim($input['propTitle'] ?? $input['property_title'] ?? 'Property Contact');
$buyerName = trim($input['buyerName'] ?? 'Customer');
$buyerPhone = trim($input['buyerPhone'] ?? '');
$buyerEmail = trim($input['buyerEmail'] ?? '');
$sellerName = trim($input['sellerName'] ?? 'Direct Owner');
$sellerPhone = trim($input['sellerPhone'] ?? '');

$recordId = 'pay_' . time() . '_' . rand(100, 999);
$newPayment = [
    'id' => $recordId,
    'paymentId' => $paymentId,
    'orderId' => $orderId,
    'signature' => $signature,
    'propId' => $propId,
    'propTitle' => $propTitle,
    'buyerName' => $buyerName,
    'buyerPhone' => $buyerPhone,
    'amount' => $amount,
    'method' => 'Razorpay Standard Checkout',
    'status' => 'completed',
    'verified' => true,
    'date' => date('c')
];

array_unshift($paymentsData['payments'], $newPayment);
$paymentsData['stats']['totalRevenue'] = ($paymentsData['stats']['totalRevenue'] ?? 0) + $amount;
$paymentsData['stats']['paidUnlocksCount'] = ($paymentsData['stats']['paidUnlocksCount'] ?? 0) + 1;

file_put_contents($paymentsFile, json_encode($paymentsData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

// Log user activity
$actFile = DATA_DIR . '/activities.json';
$acts = [];
if (file_exists($actFile)) {
    $decodedActs = json_decode(file_get_contents($actFile), true);
    if (is_array($decodedActs)) $acts = $decodedActs;
}
$actId = 'act_' . time() . '_' . rand(100, 999);
$now = date('Y-m-d H:i:s');
$actItem = [
    'id' => $actId,
    'user_name' => $buyerName,
    'user_phone' => $buyerPhone,
    'user_email' => $buyerEmail,
    'action_type' => 'contact_unlock_paid',
    'action_title' => 'கட்டண தொடர்பு எண் திறப்பு (Razorpay ₹' . $amount . ')',
    'property_id' => $propId,
    'property_title' => $propTitle,
    'seller_name' => $sellerName,
    'seller_phone' => $sellerPhone,
    'amount' => (float)$amount,
    'created_at' => $now
];
array_unshift($acts, $actItem);
file_put_contents($actFile, json_encode(array_slice($acts, 0, 2000), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

// Database logging if connected
$pdo = getDbConnection();
if ($pdo) {
    try {
        $stmt = $pdo->prepare("INSERT INTO `user_activities` (`id`, `user_name`, `user_phone`, `user_email`, `action_type`, `action_title`, `property_id`, `property_title`, `seller_name`, `seller_phone`, `amount`, `created_at`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$actId, $buyerName, $buyerPhone, $buyerEmail, 'contact_unlock_paid', 'கட்டண தொடர்பு எண் திறப்பு (Razorpay ₹' . $amount . ')', $propId, $propTitle, $sellerName, $sellerPhone, $amount, $now]);
    } catch (Exception $e) {}
}

sendResponse([
    'success' => true,
    'message' => 'Payment verified successfully.',
    'payment_id' => $paymentId,
    'order_id' => $orderId,
    'prop_id' => $propId,
    'amount' => $amount
], 200);
