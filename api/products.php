<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }

$pdo    = get_pdo();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query('SELECT id, product_name, price, stock_quantity FROM products ORDER BY price ASC');
    echo json_encode(['products' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
} elseif ($method === 'POST') {
    if (($payload['role'] ?? '') !== 'admin') api_error(403, 'Admin only');
    $data  = json_decode(file_get_contents('php://input'), true) ?? [];
    $name  = trim($data['product_name'] ?? '');
    $price = (float)($data['price'] ?? 0);
    $qty   = (int)($data['stock_quantity'] ?? 0);
    if ($name === '' || $price <= 0) api_error(400, 'Name and price required');
    $pdo->prepare('INSERT INTO products (product_name, price, stock_quantity) VALUES (?, ?, ?)')
        ->execute([$name, $price, $qty]);
    echo json_encode(['success' => true, 'id' => (int)$pdo->lastInsertId()]);
} else {
    api_error(405, 'Method not allowed');
}
