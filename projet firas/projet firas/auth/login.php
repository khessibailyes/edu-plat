<?php
// ============================================================
//  auth/login.php
// ============================================================
declare(strict_types=1);
session_start();

// Already logged in? Redirect immediately.
if (!empty($_SESSION['user_id'])) {
    header('Location: /dashboards/' . $_SESSION['role'] . '.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email    = trim($_POST['email']    ?? '');
    $password = trim($_POST['password'] ?? '');

    if ($email === '' || $password === '') {
        $error = 'Please fill in all fields.';
    } else {
        $pdo  = get_pdo();
        $stmt = $pdo->prepare('SELECT id, full_name, password, role FROM users WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password'])) {
            session_regenerate_id(true);
            $_SESSION['user_id']   = $user['id'];
            $_SESSION['full_name'] = $user['full_name'];
            $_SESSION['role']      = $user['role'];

            header('Location: /dashboards/' . $user['role'] . '.php');
            exit;
        } else {
            $error = 'Invalid email or password.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – EduPlatform</title>
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
    <h2>Welcome Back</h2>
    <p class="auth-subtitle">Sign in to your account</p>

    <?php if ($error): ?>
        <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>

    <form method="POST" action="/auth/login.php" novalidate>
        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" required
                   value="<?= htmlspecialchars($_POST['email'] ?? '') ?>"
                   placeholder="you@example.com">
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required placeholder="••••••••">
        </div>
        <button type="submit" class="btn btn-primary btn-block">Sign In</button>
    </form>
    <p class="auth-footer">Don't have an account? <a href="/auth/register.php">Register</a></p>
</div>
</body>
</html>
