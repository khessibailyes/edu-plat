<?php
// API: POST /api/register.php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$data = json_decode(file_get_contents('php://input'), true) ?? [];
$full_name = trim($data['full_name'] ?? '');
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');
$role = $data['role'] ?? 'student';

$allowed_roles = ['student', 'teacher'];
if (!in_array($role, $allowed_roles, true)) $role = 'student';

if ($full_name === '' || $email === '' || $password === '') {
    api_error(400, 'All fields required');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) api_error(400, 'Invalid email');
if (strlen($password) < 8) api_error(400, 'Password too short');

$pdo = get_pdo();
$stmt = $pdo->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
$stmt->execute([$email]);
if ($stmt->fetch()) api_error(409, 'Email already registered');

$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
$ins = $pdo->prepare('INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, ?)');
$ins->execute([$full_name, $email, $hash, $role]);
$uid = (int)$pdo->lastInsertId();

$payload = ['uid' => $uid, 'role' => $role, 'name' => $full_name, 'email' => $email];
$token = jwt_encode($payload, JWT_SECRET, 86400 * 7);

echo json_encode(['token' => $token, 'user' => $payload]);
