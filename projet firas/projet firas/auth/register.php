<?php
// ============================================================
//  auth/register.php
// ============================================================
declare(strict_types=1);
session_start();

if (!empty($_SESSION['user_id'])) {
    header('Location: /dashboards/' . $_SESSION['role'] . '.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

$error   = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $full_name = trim($_POST['full_name'] ?? '');
    $email     = trim($_POST['email']     ?? '');
    $password  = trim($_POST['password']  ?? '');
    $confirm   = trim($_POST['confirm']   ?? '');
    $role      = $_POST['role'] ?? 'student';

    // Validate role to prevent privilege escalation
    $allowed_roles = ['student', 'teacher'];
    if (!in_array($role, $allowed_roles, true)) {
        $role = 'student';
    }

    if ($full_name === '' || $email === '' || $password === '' || $confirm === '') {
        $error = 'All fields are required.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error = 'Invalid email address.';
    } elseif (strlen($password) < 8) {
        $error = 'Password must be at least 8 characters.';
    } elseif ($password !== $confirm) {
        $error = 'Passwords do not match.';
    } else {
        $pdo  = get_pdo();
        $stmt = $pdo->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);

        if ($stmt->fetch()) {
            $error = 'An account with that email already exists.';
        } else {
            $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
            $ins  = $pdo->prepare(
                'INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, ?)'
            );
            $ins->execute([$full_name, $email, $hash, $role]);
            $success = 'Account created! <a href="/auth/login.php">Sign in now</a>.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register – EduPlatform</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="auth-page">
<div class="auth-card">
    <div class="auth-logo">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
            <path d="M6 12v5c3 3 9 3 12 0v-5"/>
        </svg>
        <span>EduPlatform</span>
    </div>
    <h2>Create Account</h2>
    <p class="auth-subtitle">Join the platform today</p>

    <?php if ($error): ?>
        <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    <?php if ($success): ?>
        <div class="alert alert-success"><?= $success ?></div>
    <?php endif; ?>

    <form method="POST" action="/auth/register.php" novalidate>
        <div class="form-group">
            <label for="full_name">Full Name</label>
            <input type="text" id="full_name" name="full_name" required
                   value="<?= htmlspecialchars($_POST['full_name'] ?? '') ?>"
                   placeholder="Jane Doe">
        </div>
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" required
                   value="<?= htmlspecialchars($_POST['email'] ?? '') ?>"
                   placeholder="you@example.com">
        </div>
        <div class="form-group">
            <label for="role">I am a…</label>
            <select id="role" name="role">
                <option value="student" <?= (($_POST['role'] ?? '') === 'student') ? 'selected' : '' ?>>Student</option>
                <option value="teacher" <?= (($_POST['role'] ?? '') === 'teacher') ? 'selected' : '' ?>>Teacher</option>
            </select>
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required
                   placeholder="Min. 8 characters">
        </div>
        <div class="form-group">
            <label for="confirm">Confirm Password</label>
            <input type="password" id="confirm" name="confirm" required placeholder="••••••••">
        </div>
        <button type="submit" class="btn btn-primary btn-block">Create Account</button>
    </form>
    <p class="auth-footer">Already have an account? <a href="/auth/login.php">Sign in</a></p>
</div>
</body>
</html>
