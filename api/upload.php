<?php
// API: POST /api/upload.php (multipart/form-data)
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try {
    $payload = jwt_decode($token, JWT_SECRET);
} catch (Exception $e) {
    api_error(401, $e->getMessage());
}

if (($payload['role'] ?? '') !== 'teacher') api_error(403, 'Only teachers can upload');
if ($_SERVER['REQUEST_METHOD'] !== 'POST') api_error(405, 'Method not allowed');

$description = trim($_POST['description'] ?? '');
$upload_dir  = __DIR__ . '/../uploads/documents/';
if (!is_dir($upload_dir)) mkdir($upload_dir, 0755, true);

if (empty($_FILES['document']['name'])) api_error(400, 'No file uploaded');

$file = $_FILES['document'];
$allowed = ['pdf','doc','docx','ppt','pptx','txt','zip'];
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$max_size = 10 * 1024 * 1024;
if (!in_array($ext, $allowed, true)) api_error(400, 'File type not allowed');
if ($file['size'] > $max_size) api_error(400, 'File too large');
if ($file['error'] !== UPLOAD_ERR_OK) api_error(400, 'Upload error');

$safe_name = bin2hex(random_bytes(16)) . '.' . $ext;
$dest = $upload_dir . $safe_name;
$rel_path = 'uploads/documents/' . $safe_name;
if (!move_uploaded_file($file['tmp_name'], $dest)) api_error(500, 'Could not save file');

$pdo = get_pdo();
$stmt = $pdo->prepare('INSERT INTO documents (teacher_id, file_path, description) VALUES (?, ?, ?)');
$stmt->execute([(int)$payload['uid'], $rel_path, $description]);
$docId = (int)$pdo->lastInsertId();

echo json_encode(['success' => true, 'id' => $docId, 'file_path' => $rel_path]);
