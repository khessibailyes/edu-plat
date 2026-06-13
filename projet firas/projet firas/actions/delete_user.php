<?php
// ============================================================
//  actions/delete_user.php  (Admin only)
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

$id = (int)($_GET['id'] ?? 0);

// Prevent self-deletion
if ($id === (int)$_SESSION['user_id']) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'You cannot delete your own account.'];
    header('Location: /dashboards/admin.php');
    exit;
}

$pdo  = get_pdo();
$stmt = $pdo->prepare('DELETE FROM users WHERE id = ?');
$stmt->execute([$id]);

$_SESSION['flash'] = ['type' => 'success', 'msg' => 'User deleted.'];
header('Location: /dashboards/admin.php');
exit;
