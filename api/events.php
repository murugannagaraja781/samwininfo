<?php
require_once __DIR__ . '/config.php';

// Normalize phone to last 10 digits or preserve 'admin' target
function normalizePhone($phone) {
    $trimmed = strtolower(trim((string)$phone));
    if ($trimmed === 'admin' || $trimmed === 'super_admin' || $trimmed === 'superadmin') {
        return 'admin';
    }
    $clean = preg_replace('/[^0-9]/', '', (string)$phone);
    return strlen($clean) >= 10 ? substr($clean, -10) : $clean;
}

$eventsFile = DATA_DIR . '/realtime_events.json';

/**
 * Emit a real-time event to a target user phone
 */
function emitRealtimeEvent($targetPhone, $eventType, $payload = []) {
    global $eventsFile;
    $cleanPhone = normalizePhone($targetPhone);
    if (empty($cleanPhone)) return false;

    $event = [
        'id' => 'evt_' . time() . '_' . bin2hex(random_bytes(4)),
        'target_phone' => $cleanPhone,
        'type' => $eventType,
        'payload' => $payload,
        'timestamp' => date('c'),
        'delivered' => false,
    ];

    // Try MySQL first if available
    $pdo = getDbConnection();
    if ($pdo) {
        try {
            $pdo->exec("CREATE TABLE IF NOT EXISTS realtime_events (
                id VARCHAR(64) PRIMARY KEY,
                target_phone VARCHAR(32) NOT NULL,
                event_type VARCHAR(64) NOT NULL,
                payload LONGTEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                delivered TINYINT(1) DEFAULT 0,
                INDEX idx_phone (target_phone, delivered)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            $stmt = $pdo->prepare("INSERT INTO realtime_events (id, target_phone, event_type, payload, delivered) VALUES (?, ?, ?, ?, 0)");
            $stmt->execute([$event['id'], $cleanPhone, $eventType, json_encode($payload, JSON_UNESCAPED_UNICODE)]);
            return true;
        } catch (Exception $e) {
            // fallback to JSON
        }
    }

    // JSON file fallback
    $events = file_exists($eventsFile) ? (json_decode(file_get_contents($eventsFile), true) ?: []) : [];
    $events[] = $event;
    // Keep max 500 events
    if (count($events) > 500) {
        $events = array_slice($events, -500);
    }
    file_put_contents($eventsFile, json_encode($events, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    return true;
}

// Only execute SSE stream / direct POST if events.php is accessed directly, not when included
$currentScript = basename($_SERVER['SCRIPT_FILENAME'] ?? $_SERVER['PHP_SELF'] ?? '');
if ($currentScript !== 'events.php') {
    return;
}

// Check if this is an SSE connection
$userPhone = $_GET['user_phone'] ?? '';
$cleanUserPhone = normalizePhone($userPhone);

// If action is emit via POST (for testing or external triggers)
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $target = $input['target_phone'] ?? $input['targetPhone'] ?? '';
    $type = $input['type'] ?? 'message';
    $payload = $input['payload'] ?? [];
    if (emitRealtimeEvent($target, $type, $payload)) {
        sendResponse(['success' => true, 'message' => 'Event emitted successfully']);
    } else {
        sendResponse(['success' => false, 'message' => 'Target phone required'], 400);
    }
}

// If no user_phone provided for GET, return status
if (empty($cleanUserPhone)) {
    sendResponse(['success' => false, 'message' => 'user_phone query param required for real-time event stream']);
}

// SSE Stream Setup
if (function_exists('apache_setenv')) {
    @apache_setenv('no-gzip', '1');
}
@ini_set('zlib.output_compression', '0');
@ini_set('output_buffering', 'Off');
@ini_set('implicit_flush', 1);

header('Content-Type: text/event-stream; charset=UTF-8');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Connection: keep-alive');
header('X-Accel-Buffering: no');
header('Access-Control-Allow-Origin: *');

// Disable execution time limit for long-lived SSE
set_time_limit(0);
ignore_user_abort(true);

while (ob_get_level() > 0) {
    ob_end_flush();
}
flush();

// Send initial connected event
echo "event: connected\n";
echo "data: " . json_encode(['status' => 'connected', 'phone' => $cleanUserPhone, 'timestamp' => date('c')]) . "\n\n";
flush();

$startTime = time();
$maxDuration = 28; // Run for ~28 seconds then let client reconnect seamlessly

while (time() - $startTime < $maxDuration) {
    if (connection_aborted()) {
        break;
    }

    $undelivered = [];
    $pdo = getDbConnection();

    if ($pdo) {
        try {
            $stmt = $pdo->prepare("SELECT * FROM realtime_events WHERE target_phone = ? AND delivered = 0 ORDER BY timestamp ASC LIMIT 10");
            $stmt->execute([$cleanUserPhone]);
            $undelivered = $stmt->fetchAll();

            if (!empty($undelivered)) {
                $ids = array_column($undelivered, 'id');
                $placeholders = implode(',', array_fill(0, count($ids), '?'));
                $upStmt = $pdo->prepare("UPDATE realtime_events SET delivered = 1 WHERE id IN ($placeholders)");
                $upStmt->execute($ids);
            }
        } catch (Exception $e) {
            $undelivered = [];
        }
    } else {
        if (file_exists($eventsFile)) {
            $raw = file_get_contents($eventsFile);
            $events = json_decode($raw, true) ?: [];
            $modified = false;
            foreach ($events as &$ev) {
                if (($ev['target_phone'] ?? '') === $cleanUserPhone && empty($ev['delivered'])) {
                    $undelivered[] = [
                        'id' => $ev['id'],
                        'event_type' => $ev['type'],
                        'payload' => json_encode($ev['payload']),
                        'timestamp' => $ev['timestamp'],
                    ];
                    $ev['delivered'] = true;
                    $modified = true;
                }
            }
            if ($modified) {
                file_put_contents($eventsFile, json_encode($events, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
            }
        }
    }

    foreach ($undelivered as $eventRow) {
        $eventType = $eventRow['event_type'] ?? 'message';
        $payload = is_string($eventRow['payload']) ? json_decode($eventRow['payload'], true) : $eventRow['payload'];

        echo "event: {$eventType}\n";
        echo "data: " . json_encode([
            'id' => $eventRow['id'],
            'type' => $eventType,
            'payload' => $payload,
            'timestamp' => $eventRow['timestamp'] ?? date('c'),
        ], JSON_UNESCAPED_UNICODE) . "\n\n";
        flush();
    }

    // Ping every 10 seconds to maintain connection
    if ((time() - $startTime) % 10 === 0) {
        echo "event: ping\n";
        echo "data: " . json_encode(['time' => time()]) . "\n\n";
        flush();
    }

    // Sleep 400ms for near-instant (<500ms) event delivery
    usleep(400000);
}

// Clean closing
echo "event: close\n";
echo "data: {\"reconnect\": true}\n\n";
flush();
