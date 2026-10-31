<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$paymentsFile = DATA_DIR . '/payments.json';

function getPaymentsData($file) {
    if (!file_exists($file)) {
        return [
            'stats' => [
                'totalRevenue' => 0,
                'paidUnlocksCount' => 0,
                'freeViewsCount' => 0
            ],
            'payments' => []
        ];
    }
    $raw = file_get_contents($file);
    $data = json_decode($raw, true);
    if (!is_array($data)) {
        return [
            'stats' => ['totalRevenue' => 0, 'paidUnlocksCount' => 0, 'freeViewsCount' => 0],
            'payments' => []
        ];
    }
    return $data;
}

function savePaymentsData($file, $data) {
    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

function logUserActivityDirect($userName, $userPhone, $userEmail, $actionType, $actionTitle, $propId, $propTitle, $sellerName, $sellerPhone, $amount = 0.00) {
    $actFile = DATA_DIR . '/activities.json';
    $raw = file_exists($actFile) ? file_get_contents($actFile) : '[]';
    $acts = json_decode($raw, true);
    if (!is_array($acts)) $acts = [];
    $actId = 'act_' . time() . '_' . rand(100, 999);
    $now = date('Y-m-d H:i:s');
    $item = [
        'id' => $actId,
        'user_name' => $userName,
        'user_phone' => $userPhone,
        'user_email' => $userEmail,
        'action_type' => $actionType,
        'action_title' => $actionTitle,
        'property_id' => $propId,
        'property_title' => $propTitle,
        'seller_name' => $sellerName,
        'seller_phone' => $sellerPhone,
        'amount' => (float)$amount,
        'created_at' => $now
    ];
    array_unshift($acts, $item);
    file_put_contents($actFile, json_encode(array_slice($acts, 0, 2000), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $stmt = $pdo->prepare("INSERT INTO `user_activities` (`id`, `user_name`, `user_phone`, `user_email`, `action_type`, `action_title`, `property_id`, `property_title`, `seller_name`, `seller_phone`, `amount`, `created_at`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$actId, $userName, $userPhone, $userEmail, $actionType, $actionTitle, $propId, $propTitle, $sellerName, $sellerPhone, $amount, $now]);
        } catch (Exception $e) {}
    }
}

switch ($method) {
    case 'GET':
        $action = $_GET['action'] ?? 'list';

        $effectivePrice = OFFER_ACTIVE ? OFFER_UNLOCK_PRICE : CONTACT_UNLOCK_PRICE;
        $effectiveCount = OFFER_ACTIVE ? OFFER_CONTACTS_COUNT : UNLOCK_CONTACTS_COUNT;

        $pricingConfig = [
            'razorpayKeyId' => RAZORPAY_KEY_ID,
            'razorpayAccountId' => RAZORPAY_ACCOUNT_ID,
            'upiId' => UPI_ID,
            'unlockPrice' => CONTACT_UNLOCK_PRICE,
            'freeLimit' => FREE_CONTACT_LIMIT,
            'unlockContactsCount' => UNLOCK_CONTACTS_COUNT,
            'offerActive' => OFFER_ACTIVE,
            'offerPrice' => OFFER_UNLOCK_PRICE,
            'offerContactsCount' => OFFER_CONTACTS_COUNT,
            'offerBannerText' => OFFER_BANNER_TEXT,
            'effectivePrice' => $effectivePrice,
            'effectiveContactsCount' => $effectiveCount,
            'currency' => CURRENCY_SYMBOL,
            'currencyCode' => 'INR',
            'companyName' => COMPANY_NAME,
            'appName' => APP_NAME
        ];

        if ($action === 'config') {
            sendResponse(array_merge(['success' => true], $pricingConfig));
            break;
        }

        // Return full payments history and revenue summary
        $data = getPaymentsData($paymentsFile);
        sendResponse([
            'success' => true,
            'stats' => $data['stats'] ?? [
                'totalRevenue' => 0,
                'paidUnlocksCount' => 0,
                'freeViewsCount' => 0
            ],
            'payments' => $data['payments'] ?? [],
            'config' => $pricingConfig
        ]);
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $action = $input['action'] ?? $_GET['action'] ?? 'record_payment';

        $data = getPaymentsData($paymentsFile);
        if (!isset($data['stats'])) {
            $data['stats'] = ['totalRevenue' => 0, 'paidUnlocksCount' => 0, 'freeViewsCount' => 0];
        }
        if (!isset($data['payments'])) {
            $data['payments'] = [];
        }

        if ($action === 'save_pricing') {
            $envPath = __DIR__ . '/.env';
            if (file_exists($envPath)) {
                $lines = file($envPath, FILE_IGNORE_NEW_LINES);
                $newLines = [];
                $updates = [
                    'CONTACT_UNLOCK_PRICE' => (int)($input['CONTACT_UNLOCK_PRICE'] ?? 30),
                    'FREE_CONTACT_LIMIT' => (int)($input['FREE_CONTACT_LIMIT'] ?? 3),
                    'UNLOCK_CONTACTS_COUNT' => (int)($input['UNLOCK_CONTACTS_COUNT'] ?? 1),
                    'OFFER_ACTIVE' => (!empty($input['OFFER_ACTIVE']) && ($input['OFFER_ACTIVE'] === true || $input['OFFER_ACTIVE'] === 'true' || $input['OFFER_ACTIVE'] === 1 || $input['OFFER_ACTIVE'] === '1')) ? 'true' : 'false',
                    'OFFER_UNLOCK_PRICE' => (int)($input['OFFER_UNLOCK_PRICE'] ?? 10),
                    'OFFER_CONTACTS_COUNT' => (int)($input['OFFER_CONTACTS_COUNT'] ?? 1),
                    'OFFER_BANNER_TEXT' => '"' . trim(str_replace('"', '', $input['OFFER_BANNER_TEXT'] ?? 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!')) . '"'
                ];

                $keysHandled = [];
                foreach ($lines as $line) {
                    $trimmed = trim($line);
                    $matched = false;
                    foreach ($updates as $k => $v) {
                        if (str_starts_with($trimmed, $k . '=')) {
                            $newLines[] = $k . '=' . $v;
                            $keysHandled[$k] = true;
                            $matched = true;
                            break;
                        }
                    }
                    if (!$matched) {
                        $newLines[] = $line;
                    }
                }
                foreach ($updates as $k => $v) {
                    if (!isset($keysHandled[$k])) {
                        $newLines[] = $k . '=' . $v;
                    }
                }
                file_put_contents($envPath, implode("\n", $newLines));
            }

            sendResponse([
                'success' => true,
                'message' => 'கட்டணங்கள் மற்றும் ஆஃபர் அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன!',
                'config' => [
                    'CONTACT_UNLOCK_PRICE' => (int)($input['CONTACT_UNLOCK_PRICE'] ?? 30),
                    'FREE_CONTACT_LIMIT' => (int)($input['FREE_CONTACT_LIMIT'] ?? 3),
                    'UNLOCK_CONTACTS_COUNT' => (int)($input['UNLOCK_CONTACTS_COUNT'] ?? 1),
                    'OFFER_ACTIVE' => (!empty($input['OFFER_ACTIVE']) && ($input['OFFER_ACTIVE'] === true || $input['OFFER_ACTIVE'] === 'true')),
                    'OFFER_UNLOCK_PRICE' => (int)($input['OFFER_UNLOCK_PRICE'] ?? 10),
                    'OFFER_CONTACTS_COUNT' => (int)($input['OFFER_CONTACTS_COUNT'] ?? 1),
                    'OFFER_BANNER_TEXT' => trim(str_replace('"', '', $input['OFFER_BANNER_TEXT'] ?? ''))
                ]
            ]);
            break;
        }

        if ($action === 'record_free_view') {
            $data['stats']['freeViewsCount'] = ($data['stats']['freeViewsCount'] ?? 0) + 1;
            savePaymentsData($paymentsFile, $data);

            $buyerName = trim($input['buyerName'] ?? 'Customer');
            $buyerPhone = trim($input['buyerPhone'] ?? '');
            $buyerEmail = trim($input['buyerEmail'] ?? '');
            $propId = trim($input['propId'] ?? '');
            $propTitle = trim($input['propTitle'] ?? 'Property Contact');
            $sellerName = trim($input['sellerName'] ?? 'Direct Owner');
            $sellerPhone = trim($input['sellerPhone'] ?? '');

            logUserActivityDirect($buyerName, $buyerPhone, $buyerEmail, 'contact_unlock_free', 'இலவச தொடர்பு எண் பார்வை (Free Unlock)', $propId, $propTitle, $sellerName, $sellerPhone, 0.00);

            sendResponse([
                'success' => true,
                'message' => 'Free contact view recorded',
                'freeViewsCount' => $data['stats']['freeViewsCount']
            ]);
            break;
        }

        if ($action === 'record_payment' || $action === 'unlock_contact') {
            $amount = (int)($input['amount'] ?? CONTACT_UNLOCK_PRICE);
            $paymentId = trim($input['paymentId'] ?? ('pay_' . uniqid()));
            $propId = trim($input['propId'] ?? 'unknown');
            $propTitle = trim($input['propTitle'] ?? 'Property Contact');
            $buyerName = trim($input['buyerName'] ?? 'Customer (Guest)');
            $buyerPhone = trim($input['buyerPhone'] ?? '');
            $buyerEmail = trim($input['buyerEmail'] ?? '');
            $sellerName = trim($input['sellerName'] ?? 'Direct Owner');
            $sellerPhone = trim($input['sellerPhone'] ?? '');
            $methodType = trim($input['method'] ?? 'Razorpay UPI');

            $newPayment = [
                'id' => 'pay_' . time() . '_' . rand(100, 999),
                'paymentId' => $paymentId,
                'propId' => $propId,
                'propTitle' => $propTitle,
                'buyerName' => $buyerName,
                'buyerPhone' => $buyerPhone,
                'amount' => $amount,
                'method' => $methodType,
                'status' => 'completed',
                'date' => date('c')
            ];

            array_unshift($data['payments'], $newPayment);
            $data['stats']['totalRevenue'] = ($data['stats']['totalRevenue'] ?? 0) + $amount;
            $data['stats']['paidUnlocksCount'] = ($data['stats']['paidUnlocksCount'] ?? 0) + 1;

            savePaymentsData($paymentsFile, $data);

            logUserActivityDirect($buyerName, $buyerPhone, $buyerEmail, 'contact_unlock_paid', 'கட்டண தொடர்பு எண் திறப்பு (Paid Unlock ₹' . $amount . ')', $propId, $propTitle, $sellerName, $sellerPhone, $amount);

            sendResponse([
                'success' => true,
                'message' => '✅ பணம் வெற்றிகரமாக பெறப்பட்டது! தொடர்பு எண் திறக்கப்பட்டது.',
                'payment' => $newPayment,
                'stats' => $data['stats']
            ]);
            break;
        }

        if ($action === 'create_order' || $action === 'create-order') {
            $amount = isset($input['amount']) ? (int)$input['amount'] : 0;
            // If amount is passed in Rupees (e.g. 10 or 30), convert to paise (10 * 100 = 1000 paise)
            if ($amount > 0 && $amount < 100) {
                $amount = $amount * 100;
            }
            if ($amount < 100) {
                sendResponse(['success' => false, 'error' => 'Invalid amount. Minimum amount is 100 paise (₹1.00).'], 400);
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
                sendResponse(['success' => false, 'error' => 'cURL error connecting to Razorpay: ' . $curlError], 500);
            }

            $result = json_decode($response, true);
            if ($httpCode === 401) {
                sendResponse(['success' => false, 'error' => 'Razorpay authentication failed: Invalid Key ID or Key Secret.'], 401);
            }
            if ($httpCode < 200 || $httpCode >= 300 || empty($result['id'])) {
                $errorMessage = $result['error']['description'] ?? $result['error']['message'] ?? 'Razorpay API error creating order.';
                sendResponse(['success' => false, 'error' => $errorMessage, 'razorpay_error' => $result['error'] ?? null], 500);
            }

            sendResponse([
                'success' => true,
                'order_id' => $result['id'],
                'amount' => $result['amount'],
                'currency' => $result['currency'],
                'key_id' => RAZORPAY_KEY_ID
            ], 200);
            break;
        }

        if ($action === 'verify_payment' || $action === 'verify-payment') {
            $orderId = trim($input['razorpay_order_id'] ?? '');
            $paymentId = trim($input['razorpay_payment_id'] ?? '');
            $signature = trim($input['razorpay_signature'] ?? '');

            if (empty($orderId) || empty($paymentId) || empty($signature)) {
                sendResponse([
                    'success' => false,
                    'error' => 'Missing required payment verification fields (razorpay_order_id, razorpay_payment_id, razorpay_signature).'
                ], 400);
            }

            $expectedSignature = hash_hmac('sha256', $orderId . '|' . $paymentId, RAZORPAY_KEY_SECRET);
            if (!hash_equals($expectedSignature, $signature)) {
                sendResponse([
                    'success' => false,
                    'error' => 'Payment signature verification failed. The transaction may be tampered or invalid.'
                ], 400);
            }

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

            array_unshift($data['payments'], $newPayment);
            $data['stats']['totalRevenue'] = ($data['stats']['totalRevenue'] ?? 0) + $amount;
            $data['stats']['paidUnlocksCount'] = ($data['stats']['paidUnlocksCount'] ?? 0) + 1;
            savePaymentsData($paymentsFile, $data);

            logUserActivityDirect($buyerName, $buyerPhone, $buyerEmail, 'contact_unlock_paid', 'கட்டண தொடர்பு எண் திறப்பு (Razorpay ₹' . $amount . ')', $propId, $propTitle, $sellerName, $sellerPhone, $amount);

            sendResponse([
                'success' => true,
                'message' => 'Payment verified successfully.',
                'payment_id' => $paymentId,
                'order_id' => $orderId,
                'prop_id' => $propId,
                'amount' => $amount
            ], 200);
            break;
        }

        sendResponse(['success' => false, 'message' => 'Invalid action: ' . var_export($action, true), 'input' => $input], 400);
        break;

    default:
        sendResponse(['success' => false, 'message' => 'Method not allowed'], 405);
        break;
}
