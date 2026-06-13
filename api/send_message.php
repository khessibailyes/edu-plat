<?php
// API: POST /api/send_message.php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try {
    $payload = jwt_decode($token, JWT_SECRET);
} catch (Exception $e) {
    api_error(401, $e->getMessage());
}

$data = json_decode(file_get_contents('php://input'), true) ?? [];
$content = trim($data['content'] ?? '');
$receiver_id = $data['receiver_id'] ?? '';
$type = $data['type'] ?? 'private';

if (!in_array($type, ['private','public'], true)) $type = 'private';

if ($content === '' || $receiver_id === '') api_error(400, 'Content and receiver required');

// Only admin can send to all
if ($receiver_id === 'all' && ($payload['role'] ?? '') !== 'admin') api_error(403, 'Only admin can broadcast');

$pdo = get_pdo();
$stmt = $pdo->prepare('INSERT INTO messages (sender_id, receiver_id, content, type) VALUES (?, ?, ?, ?)');
$stmt->execute([(int)$payload['uid'], $receiver_id, $content, $type]);

echo json_encode(['success' => true]);
