<?php
require_once __DIR__ . '/api/config.php';

header('Content-Type: text/html; charset=utf-8');

// 1. Extract and sanitize parameters
$propertyId = trim($_GET['property_id'] ?? $_GET['id'] ?? '');
$buyerName = trim($_GET['buyer_name'] ?? $_GET['name'] ?? 'SamWin Buyer');
$buyerPhone = trim($_GET['buyer_phone'] ?? $_GET['phone'] ?? '9894174944');
$buyerEmail = trim($_GET['buyer_email'] ?? $_GET['email'] ?? 'buyer@tenkasidreams.com');
$method = trim($_GET['method'] ?? 'Call');

$price = OFFER_ACTIVE ? OFFER_UNLOCK_PRICE : CONTACT_UNLOCK_PRICE;
if (isset($_GET['amount']) && (int)$_GET['amount'] > 0) {
    $price = (int)$_GET['amount'];
}

// 2. Fetch property details
$propTitle = 'ரியல் எஸ்டேட் சொத்து';
$sellerName = 'உரிமையாளர்';
$sellerPhone = ADMIN_PHONE;

if (!empty($propertyId)) {
    try {
        $pdo = getDbConnection();
        if ($pdo) {
            $stmt = $pdo->prepare("SELECT `title`, `agent_name`, `agent_phone` FROM `properties` WHERE `id` = ? LIMIT 1");
            $stmt->execute([$propertyId]);
            $p = $stmt->fetch();
            if ($p) {
                $propTitle = $p['title'] ?? $propTitle;
                $sellerName = $p['agent_name'] ?? $sellerName;
                $sellerPhone = $p['agent_phone'] ?? $sellerPhone;
            }
        }
    } catch (Exception $e) {}
}

$razorpayKeyId = RAZORPAY_KEY_ID;
$isLive = (RAZORPAY_MODE === 'live');
?>
<!DOCTYPE html>
<html lang="ta">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>பாதுகாப்பான கட்டணம் | தென்காசி கனவுகள்</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif; }
    body {
      background: linear-gradient(135deg, #0F172A 0%, #0D3B66 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 16px;
      color: #0F172A;
    }
    .checkout-card {
      background: #FFFFFF;
      width: 100%;
      max-width: 440px;
      border-radius: 28px;
      overflow: hidden;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
      position: relative;
    }
    .card-header {
      background: linear-gradient(135deg, #0D47A1, #0284C7);
      padding: 30px 24px 24px;
      text-align: center;
      color: #FFFFFF;
      position: relative;
    }
    .brand-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(255, 255, 255, 0.15);
      backdrop-filter: blur(10px);
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 700;
      margin-bottom: 12px;
    }
    .mode-pill {
      font-size: 11px;
      font-weight: 800;
      padding: 2px 8px;
      border-radius: 12px;
      text-transform: uppercase;
      background: <?php echo $isLive ? '#10B981' : '#F59E0B'; ?>;
      color: #FFFFFF;
    }
    .title {
      font-size: 22px;
      font-weight: 800;
      margin-bottom: 6px;
    }
    .subtitle {
      font-size: 13.5px;
      opacity: 0.9;
    }
    .card-body {
      padding: 24px;
    }
    .prop-box {
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 16px;
      padding: 16px;
      margin-bottom: 20px;
    }
    .prop-label {
      font-size: 11.5px;
      font-weight: 700;
      color: #64748B;
      text-transform: uppercase;
      margin-bottom: 4px;
    }
    .prop-name {
      font-size: 15px;
      font-weight: 700;
      color: #1E293B;
      margin-bottom: 8px;
    }
    .price-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 10px;
      border-top: 1px dashed #CBD5E1;
    }
    .price-tag {
      font-size: 26px;
      font-weight: 800;
      color: #059669;
    }
    .original-price {
      font-size: 14px;
      text-decoration: line-through;
      color: #94A3B8;
      margin-right: 6px;
    }
    .btn-pay {
      width: 100%;
      height: 54px;
      border: none;
      outline: none;
      border-radius: 16px;
      background: linear-gradient(135deg, #0D47A1, #0284C7);
      color: #FFFFFF;
      font-size: 16px;
      font-weight: 700;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      box-shadow: 0 10px 20px -5px rgba(2, 132, 199, 0.4);
      transition: all 0.2s ease;
    }
    .btn-pay:hover {
      opacity: 0.95;
      transform: translateY(-1px);
    }
    .upi-badges {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 12px;
      margin-top: 16px;
      font-size: 12px;
      color: #64748B;
      font-weight: 600;
    }
    .security-note {
      text-align: center;
      font-size: 12px;
      color: #94A3B8;
      margin-top: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
    }
    #successBox {
      display: none;
      text-align: center;
      padding: 10px 0;
    }
    .success-icon {
      width: 70px;
      height: 70px;
      border-radius: 50%;
      background: #DCFCE7;
      color: #15803D;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 36px;
      margin: 0 auto 16px;
    }
    .seller-contact-card {
      background: #F0FDF4;
      border: 1.5px solid #86EFAC;
      border-radius: 18px;
      padding: 18px;
      margin: 18px 0;
    }
    .btn-action-group {
      display: flex;
      gap: 10px;
      margin-top: 12px;
    }
    .btn-action {
      flex: 1;
      height: 46px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      font-weight: 700;
      font-size: 14px;
      text-decoration: none;
      color: white;
    }
    .btn-call { background: #0284C7; }
    .btn-wa { background: #16A34A; }
  </style>
</head>
<body>

<div class="checkout-card">
  <div class="card-header">
    <div class="brand-badge">
      <span>🏛️ தென்காசி கனவுகள்</span>
      <span class="mode-pill"><?php echo $isLive ? 'LIVE' : 'TEST MODE'; ?></span>
    </div>
    <h1 class="title">தொடர்பு எண் திறப்பு</h1>
    <p class="subtitle">உரிமையாளருடன் நேரடியாக பேசி சொத்தை வாங்குங்கள்</p>
  </div>

  <div class="card-body">
    <!-- Step 1: Pre-Payment Details -->
    <div id="paymentBox">
      <div class="prop-box">
        <div class="prop-label">தேர்ந்தெடுக்கப்பட்ட சொத்து</div>
        <div class="prop-name"><?php echo htmlspecialchars($propTitle); ?></div>
        
        <div class="price-row">
          <div>
            <span style="font-size: 12px; color: #64748B;">கட்டணம்:</span><br>
            <span class="original-price">₹30</span>
            <span class="price-tag">₹<?php echo $price; ?></span>
          </div>
          <span style="background: #FEF3C7; color: #B45309; font-size: 11.5px; font-weight: 700; padding: 4px 10px; border-radius: 20px;">
            🎉 சிறப்பு தள்ளுபடி
          </span>
        </div>
      </div>

      <button id="btnPayNow" class="btn-pay" onclick="launchRazorpay()">
        <span>💳 ₹<?php echo $price; ?> செலுத்தி திறக்க</span>
      </button>

      <div class="upi-badges">
        <span>GPay</span> • <span>PhonePe</span> • <span>Paytm</span> • <span>UPI / Cards</span>
      </div>

      <div class="security-note">
        🔒 256-Bit SSL பாதுகாப்பான Razorpay Gateway
      </div>
    </div>

    <!-- Step 2: Post-Payment Success -->
    <div id="successBox">
      <div class="success-icon">✓</div>
      <h2 style="font-size: 20px; font-weight: 800; color: #166534; margin-bottom: 6px;">பணம் வெற்றிகரமாக பெறப்பட்டது!</h2>
      <p style="font-size: 13.5px; color: #475569;">உரிமையாளரின் தொடர்பு விவரங்கள் திறக்கப்பட்டுவிட்டன.</p>

      <div class="seller-contact-card">
        <div style="font-size: 12px; color: #64748B; margin-bottom: 4px;">சொத்து உரிமையாளர்:</div>
        <div style="font-size: 17px; font-weight: 800; color: #0F172A;" id="resSellerName"><?php echo htmlspecialchars($sellerName); ?></div>
        <div style="font-size: 20px; font-weight: 800; color: #0284C7; letter-spacing: 1px; margin-top: 6px;" id="resSellerPhone"><?php echo htmlspecialchars($sellerPhone); ?></div>

        <div class="btn-action-group">
          <a id="btnCallSeller" href="tel:<?php echo htmlspecialchars($sellerPhone); ?>" class="btn-action btn-call">
            📞 அழைக்க
          </a>
          <a id="btnWaSeller" href="https://wa.me/<?php echo preg_replace('/[^0-9]/', '', $sellerPhone); ?>" target="_blank" class="btn-action btn-wa">
            💬 WhatsApp
          </a>
        </div>
      </div>

      <button onclick="handleAppDone();" class="btn-pay" style="background: #334155; margin-top: 10px;">
        செயலிக்கு திரும்பவும் (Done)
      </button>
    </div>
  </div>
</div>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
const CONFIG = {
  propertyId: <?php echo json_encode($propertyId); ?>,
  propertyTitle: <?php echo json_encode($propTitle); ?>,
  price: <?php echo (int)$price; ?>,
  buyerName: <?php echo json_encode($buyerName); ?>,
  buyerPhone: <?php echo json_encode($buyerPhone); ?>,
  buyerEmail: <?php echo json_encode($buyerEmail); ?>,
  keyId: <?php echo json_encode($razorpayKeyId); ?>
};

async function launchRazorpay() {
  const btn = document.getElementById('btnPayNow');
  btn.disabled = true;
  btn.innerHTML = '<span>⏳ ஆர்டர் துவங்குகிறது...</span>';

  try {
    // 1. Create order on backend
    const amountInPaise = CONFIG.price >= 100 ? CONFIG.price : (CONFIG.price * 100);
    const orderRes = await fetch('api/create_order.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        property_id: CONFIG.propertyId,
        property_title: CONFIG.propertyTitle,
        amount: amountInPaise,
        buyer_name: CONFIG.buyerName,
        buyer_phone: CONFIG.buyerPhone,
        buyer_email: CONFIG.buyerEmail
      })
    });
    const orderData = await orderRes.json();

    if (!orderData.success || !orderData.order_id) {
      throw new Error(orderData.error || 'Order creation failed');
    }

    // 2. Open Razorpay Modal
    const options = {
      key: orderData.key_id || CONFIG.keyId,
      amount: orderData.amount,
      currency: orderData.currency || 'INR',
      name: 'தென்காசி கனவுகள்',
      description: 'உரிமையாளர் தொடர்பு எண் திறப்பு',
      order_id: orderData.order_id,
      prefill: {
        name: CONFIG.buyerName,
        email: CONFIG.buyerEmail,
        contact: CONFIG.buyerPhone
      },
      notes: {
        property_id: CONFIG.propertyId,
        buyer_phone: CONFIG.buyerPhone
      },
      theme: {
        color: '#0D47A1'
      },
      config: {
        display: {
          blocks: {
            upi: {
              name: 'Pay using UPI (GPay / PhonePe / Paytm / QR)',
              instruments: [
                { method: 'upi' }
              ]
            },
            other: {
              name: 'Cards / NetBanking / Wallets',
              instruments: [
                { method: 'card' },
                { method: 'netbanking' },
                { method: 'wallet' }
              ]
            }
          },
          sequence: ['block.upi', 'block.other'],
          preferences: {
            show_default_blocks: true
          }
        }
      },
      handler: async function(response) {
        btn.innerHTML = '<span>⏳ கட்டணம் சரிபார்க்கப்படுகிறது...</span>';
        await verifyPayment(response);
      },
      modal: {
        ondismiss: function() {
          btn.disabled = false;
          btn.innerHTML = '<span>💳 ₹' + CONFIG.price + ' செலுத்தி திறக்க</span>';
        }
      }
    };

    const rzp = new Razorpay(options);
    rzp.open();

  } catch (err) {
    alert('❌ பிழை: ' + err.message);
    btn.disabled = false;
    btn.innerHTML = '<span>💳 ₹' + CONFIG.price + ' செலுத்தி திறக்க</span>';
  }
}

async function verifyPayment(rzpResp) {
  try {
    const res = await fetch('api/verify_payment.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        razorpay_order_id: rzpResp.razorpay_order_id,
        razorpay_payment_id: rzpResp.razorpay_payment_id,
        razorpay_signature: rzpResp.razorpay_signature,
        property_id: CONFIG.propertyId,
        amount: CONFIG.price,
        buyer_name: CONFIG.buyerName,
        buyer_phone: CONFIG.buyerPhone,
        buyer_email: CONFIG.buyerEmail
      })
    });
    const data = await res.json();

    if (data.success) {
      document.getElementById('paymentBox').style.display = 'none';
      document.getElementById('successBox').style.display = 'block';
      if (data.seller_phone) {
        document.getElementById('resSellerPhone').innerText = data.seller_phone;
        document.getElementById('btnCallSeller').href = 'tel:' + data.seller_phone;
        document.getElementById('btnWaSeller').href = 'https://wa.me/' + data.seller_phone.replace(/[^0-9]/g, '');
      }
      if (window.FlutterApp && typeof window.FlutterApp.postMessage === 'function') {
        window.FlutterApp.postMessage('payment_success');
      }
    } else {
      alert('❌ பணம் சரிபார்ப்பு தோல்வி: ' + (data.error || 'Unknown error'));
    }
  } catch (e) {
    alert('❌ சரிபார்ப்பு பிழை: ' + e.message);
  }
}

function handleAppDone() {
  if (window.FlutterApp && typeof window.FlutterApp.postMessage === 'function') {
    window.FlutterApp.postMessage('payment_done');
  } else {
    try { window.close(); } catch (e) {}
    window.location.href = '/close_webview';
  }
}

// Auto-launch checkout on page load if opened from app
window.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    launchRazorpay();
  }, 400);
});
</script>

</body>
</html>
