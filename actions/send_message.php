<?php
// ============================================================
//  actions/send_message.php
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id'])) {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: /dashboards/' . $_SESSION['role'] . '.php');
    exit;
}

$content     = trim($_POST['content']     ?? '');
$receiver_id = trim($_POST['receiver_id'] ?? '');
$type        = $_POST['type'] ?? 'private';

if (!in_array($type, ['private', 'public'], true)) $type = 'private';

// Only admin can broadcast to 'all'
if ($receiver_id === 'all' && $_SESSION['role'] !== 'admin') {
    $receiver_id = '';
}

if ($content === '' || $receiver_id === '') {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Message content and recipient are required.'];
    header('Location: /dashboards/' . $_SESSION['role'] . '.php');
    exit;
}

$pdo  = get_pdo();
$stmt = $pdo->prepare(
    'INSERT INTO messages (sender_id, receiver_id, content, type) VALUES (?, ?, ?, ?)'
);
$stmt->execute([(int)$_SESSION['user_id'], $receiver_id, $content, $type]);

$_SESSION['flash'] = ['type' => 'success', 'msg' => 'Message sent successfully.'];
header('Location: /dashboards/' . $_SESSION['role'] . '.php');
exit;
