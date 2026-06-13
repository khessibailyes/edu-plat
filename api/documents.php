<?php
// API: GET /api/documents.php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try {
    $payload = jwt_decode($token, JWT_SECRET);
} catch (Exception $e) {
    api_error(401, $e->getMessage());
}

$pdo = get_pdo();

if (($payload['role'] ?? '') === 'teacher') {
    // teacher: return own documents
    $stmt = $pdo->prepare('SELECT id, teacher_id, file_path, description, upload_date FROM documents WHERE teacher_id = ? ORDER BY upload_date DESC');
    $stmt->execute([(int)$payload['uid']]);
    $docs = $stmt->fetchAll();
    echo json_encode(['documents' => $docs]);
    exit;
}

// student or other: return all documents with teacher name
$stmt = $pdo->query('SELECT d.id, d.teacher_id, d.file_path, d.description, d.upload_date, u.full_name AS teacher_name FROM documents d JOIN users u ON u.id = d.teacher_id ORDER BY d.upload_date DESC');
$docs = $stmt->fetchAll();
echo json_encode(['documents' => $docs]);
