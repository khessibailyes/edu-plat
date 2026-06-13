<?php
// ============================================================
//  actions/update_profile.php  (Student)
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'student') {
    header('Location: /auth/login.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: /dashboards/student.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

$full_name = trim($_POST['full_name'] ?? '');
$email     = trim($_POST['email']     ?? '');
$password  = trim($_POST['password']  ?? '');
$confirm   = trim($_POST['confirm']   ?? '');
$uid       = (int)$_SESSION['user_id'];

if ($full_name === '' || $email === '') {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Name and email are required.'];
    header('Location: /dashboards/student.php');
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Invalid email address.'];
    header('Location: /dashboards/student.php');
    exit;
}

$pdo = get_pdo();

// Check email uniqueness (exclude self)
$check = $pdo->prepare('SELECT id FROM users WHERE email = ? AND id != ? LIMIT 1');
$check->execute([$email, $uid]);
if ($check->fetch()) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'That email is already in use.'];
    header('Location: /dashboards/student.php');
    exit;
}

if ($password !== '') {
    if (strlen($password) < 8) {
        $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Password must be at least 8 characters.'];
        header('Location: /dashboards/student.php');
        exit;
    }
    if ($password !== $confirm) {
        $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Passwords do not match.'];
        header('Location: /dashboards/student.php');
        exit;
    }
    $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    $stmt = $pdo->prepare('UPDATE users SET full_name = ?, email = ?, password = ? WHERE id = ?');
    $stmt->execute([$full_name, $email, $hash, $uid]);
} else {
    $stmt = $pdo->prepare('UPDATE users SET full_name = ?, email = ? WHERE id = ?');
    $stmt->execute([$full_name, $email, $uid]);
}

$_SESSION['full_name'] = $full_name;
$_SESSION['flash']     = ['type' => 'success', 'msg' => 'Profile updated successfully.'];
header('Location: /dashboards/student.php');
exit;
