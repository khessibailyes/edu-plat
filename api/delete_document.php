<?php
declare(strict_types=1);
require_once __DIR__ . '/bootstrap.php';

$token = get_bearer_token();
if (!$token) api_error(401, 'Missing Authorization header');
try { $payload = jwt_decode($token, JWT_SECRET); } catch (Exception $e) { api_error(401, $e->getMessage()); }
if (($payload['role'] ?? '') !== 'teacher') api_error(403, 'Only teachers can delete documents');

$data   = json_decode(file_get_contents('php://input'), true) ?? [];
$doc_id = (int)($data['id'] ?? 0);
if ($doc_id <= 0) api_error(400, 'Invalid document id');

$uid = (int)$payload['uid'];
$pdo = get_pdo();

$stmt = $pdo->prepare('SELECT file_path FROM documents WHERE id = ? AND teacher_id = ?');
$stmt->execute([$doc_id, $uid]);
$doc = $stmt->fetch();
if (!$doc) api_error(404, 'Document not found or not yours');

$file_path = __DIR__ . '/../' . $doc['file_path'];
if (file_exists($file_path)) @unlink($file_path);
$pdo->prepare('DELETE FROM documents WHERE id = ?')->execute([$doc_id]);

echo json_encode(['success' => true]);
