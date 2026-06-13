<?php
// ============================================================
//  actions/save_product.php  (Admin only)
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: /auth/login.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: /dashboards/admin.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

$name     = trim($_POST['product_name']    ?? '');
$price    = (float)($_POST['price']         ?? 0);
$quantity = (int)($_POST['stock_quantity']  ?? 0);

if ($name === '' || $price < 0 || $quantity < 0) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Invalid product data.'];
    header('Location: /dashboards/admin.php');
    exit;
}

$pdo  = get_pdo();
$stmt = $pdo->prepare(
    'INSERT INTO products (product_name, price, stock_quantity) VALUES (?, ?, ?)'
);
$stmt->execute([$name, $price, $quantity]);

$_SESSION['flash'] = ['type' => 'success', 'msg' => 'Product added.'];
header('Location: /dashboards/admin.php');
exit;
