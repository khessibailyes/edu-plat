<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }

$uid  = (int)$payload['uid'];
$role = $payload['role'] ?? '';
$pdo  = get_pdo();

if ($role === 'admin') {
    $stmt = $pdo->query(
        'SELECT m.id, m.content, m.type, m.timestamp, m.receiver_id,
                u.full_name AS sender_name, u.role AS sender_role
         FROM messages m JOIN users u ON u.id = m.sender_id
         ORDER BY m.timestamp DESC'
    );
} elseif ($role === 'teacher') {
    $stmt = $pdo->prepare(
        'SELECT m.id, m.content, m.type, m.timestamp, m.sender_id,
                u.full_name AS sender_name, u.email AS sender_email
         FROM messages m JOIN users u ON u.id = m.sender_id
         WHERE m.receiver_id = ?
         ORDER BY m.timestamp DESC'
    );
    $stmt->execute([(string)$uid]);
} else {
    $stmt = $pdo->prepare(
        'SELECT m.id, m.content, m.type, m.timestamp,
                u.full_name AS sender_name, u.role AS sender_role
         FROM messages m JOIN users u ON u.id = m.sender_id
         WHERE m.receiver_id = ? OR m.receiver_id = \'all\'
         ORDER BY m.timestamp DESC'
    );
    $stmt->execute([(string)$uid]);
}

echo json_encode(['messages' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
