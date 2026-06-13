<?php
// API: POST /api/login.php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$data = json_decode(file_get_contents('php://input'), true) ?? [];
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

if ($email === '' || $password === '') {
    api_error(400, 'Email and password required');
}

$pdo = get_pdo();
$stmt = $pdo->prepare('SELECT id, full_name, password, role, email FROM users WHERE email = ? LIMIT 1');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password'])) {
    api_error(401, 'Invalid credentials');
}

$payload = [
    'uid' => (int)$user['id'],
    'role' => $user['role'],
    'name' => $user['full_name'],
    'email' => $user['email']
];
$token = jwt_encode($payload, JWT_SECRET, 86400 * 7); // 7 days

echo json_encode(['token' => $token, 'user' => $payload]);
