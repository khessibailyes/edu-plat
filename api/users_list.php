<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }
if (($payload['role'] ?? '') !== 'admin') api_error(403, 'Admin only');

$pdo  = get_pdo();
$stmt = $pdo->query('SELECT id, full_name, email, role, created_at FROM users ORDER BY full_name');
echo json_encode(['users' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
