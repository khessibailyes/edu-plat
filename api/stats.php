<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }
if (($payload['role'] ?? '') !== 'admin') api_error(403, 'Admin only');

$pdo = get_pdo();
echo json_encode([
    'total_users'     => (int)$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn(),
    'total_teachers'  => (int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='teacher'")->fetchColumn(),
    'total_students'  => (int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='student'")->fetchColumn(),
    'total_documents' => (int)$pdo->query('SELECT COUNT(*) FROM documents')->fetchColumn(),
    'total_messages'  => (int)$pdo->query('SELECT COUNT(*) FROM messages')->fetchColumn(),
    'total_products'  => (int)$pdo->query('SELECT COUNT(*) FROM products')->fetchColumn(),
]);
