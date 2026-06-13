<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }

$uid  = (int)$payload['uid'];
$data = json_decode(file_get_contents('php://input'), true) ?? [];
$full_name    = trim($data['full_name'] ?? '');
$email        = trim($data['email'] ?? '');
$new_password = $data['password'] ?? '';

if ($full_name === '' || $email === '') api_error(400, 'Name and email required');
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) api_error(400, 'Invalid email');

$pdo = get_pdo();
$stmt = $pdo->prepare('SELECT id FROM users WHERE email = ? AND id != ?');
$stmt->execute([$email, $uid]);
if ($stmt->fetch()) api_error(409, 'Email already in use');

if ($new_password !== '') {
    if (strlen($new_password) < 8) api_error(400, 'Password must be at least 8 characters');
    $hash = password_hash($new_password, PASSWORD_BCRYPT);
    $pdo->prepare('UPDATE users SET full_name = ?, email = ?, password = ? WHERE id = ?')
        ->execute([$full_name, $email, $hash, $uid]);
} else {
    $pdo->prepare('UPDATE users SET full_name = ?, email = ? WHERE id = ?')
        ->execute([$full_name, $email, $uid]);
}

$user = $pdo->prepare('SELECT id, full_name, email, role FROM users WHERE id = ?');
$user->execute([$uid]);
$u = $user->fetch(PDO::FETCH_ASSOC);
echo json_encode(['success' => true, 'user' => [
    'uid'   => (int)$u['id'],
    'name'  => $u['full_name'],
    'email' => $u['email'],
    'role'  => $u['role'],
]]);
