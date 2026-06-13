<?php
// ============================================================
//  index.php  –  Entry point: redirect based on session
// ============================================================
declare(strict_types=1);
session_start();

if (!empty($_SESSION['user_id'])) {
    header('Location: /dashboards/' . $_SESSION['role'] . '.php');
} else {
    header('Location: /auth/login.php');
}
exit;
