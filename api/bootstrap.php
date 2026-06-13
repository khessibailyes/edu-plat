<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/jwt.php';
require_once __DIR__ . '/jwt.php';

function api_error(int $code, string $msg): void
{
    http_response_code($code);
    echo json_encode(['error' => $msg]);
    exit;
}

function get_bearer_token(): ?string
{
    $hdr = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (!$hdr) return null;
    if (stripos($hdr, 'bearer ') === 0) return trim(substr($hdr, 7));
    return null;
}
