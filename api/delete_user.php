<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }
if (($payload['role'] ?? '') !== 'admin') api_error(403, 'Admin only');

$data    = json_decode(file_get_contents('php://input'), true) ?? [];
$user_id = (int)($data['id'] ?? 0);
if ($user_id <= 0) api_error(400, 'Invalid user id');
if ($user_id === (int)$payload['uid']) api_error(400, 'Cannot delete yourself');

$pdo = get_pdo();
$pdo->prepare('DELETE FROM users WHERE id = ?')->execute([$user_id]);
echo json_encode(['success' => true]);
