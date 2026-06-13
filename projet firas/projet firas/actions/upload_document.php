<?php
// ============================================================
//  actions/upload_document.php
// ============================================================
declare(strict_types=1);
session_start();

if (empty($_SESSION['user_id']) || $_SESSION['role'] !== 'teacher') {
    header('Location: /auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: /dashboards/teacher.php');
    exit;
}

$description = trim($_POST['description'] ?? '');
$upload_dir  = __DIR__ . '/../uploads/documents/';

if (!is_dir($upload_dir)) {
    mkdir($upload_dir, 0755, true);
}

if (empty($_FILES['document']['name'])) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'No file selected.'];
    header('Location: /dashboards/teacher.php');
    exit;
}

$file     = $_FILES['document'];
$allowed  = ['pdf','doc','docx','ppt','pptx','txt','zip'];
$ext      = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$max_size = 10 * 1024 * 1024; // 10 MB

if (!in_array($ext, $allowed, true)) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'File type not allowed.'];
    header('Location: /dashboards/teacher.php');
    exit;
}

if ($file['size'] > $max_size) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'File exceeds 10 MB limit.'];
    header('Location: /dashboards/teacher.php');
    exit;
}

if ($file['error'] !== UPLOAD_ERR_OK) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Upload error, please try again.'];
    header('Location: /dashboards/teacher.php');
    exit;
}

// Safe random filename to prevent path traversal
$safe_name = bin2hex(random_bytes(16)) . '.' . $ext;
$dest      = $upload_dir . $safe_name;
$rel_path  = 'uploads/documents/' . $safe_name;

if (!move_uploaded_file($file['tmp_name'], $dest)) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Could not save file.'];
    header('Location: /dashboards/teacher.php');
    exit;
}

$pdo  = get_pdo();
$stmt = $pdo->prepare(
    'INSERT INTO documents (teacher_id, file_path, description) VALUES (?, ?, ?)'
);
$stmt->execute([(int)$_SESSION['user_id'], $rel_path, $description]);

$_SESSION['flash'] = ['type' => 'success', 'msg' => 'Document uploaded successfully.'];
header('Location: /dashboards/teacher.php');
exit;
