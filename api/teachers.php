<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }

$pdo  = get_pdo();
$stmt = $pdo->query("SELECT id, full_name, email FROM users WHERE role='teacher' ORDER BY full_name");
echo json_encode(['teachers' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
