<?php
// ============================================================
//  actions/delete_document.php
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'teacher') {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

$id  = (int)($_GET['id'] ?? 0);
$pdo = get_pdo();

// Fetch doc – ensure ownership
$stmt = $pdo->prepare('SELECT * FROM documents WHERE id = ? AND teacher_id = ?');
$stmt->execute([$id, (int)$_SESSION['user_id']]);
$doc = $stmt->fetch();

if ($doc) {
    // Remove physical file
    $path = __DIR__ . '/../' . $doc['file_path'];
    if (file_exists($path)) unlink($path);

    $del = $pdo->prepare('DELETE FROM documents WHERE id = ?');
    $del->execute([$id]);
    $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Document deleted.'];
} else {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Document not found or access denied.'];
}

header('Location: /dashboards/teacher.php');
exit;
