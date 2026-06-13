<?php
if (($_GET['k'] ?? '') !== 'edu2024diag') { http_response_code(404); exit; }
header('Content-Type: application/json');

$host = getenv('MYSQLHOST')     ?: 'NOT SET';
$port = getenv('MYSQLPORT')     ?: 'NOT SET';
$db   = getenv('MYSQLDATABASE') ?: 'NOT SET';
$user = getenv('MYSQLUSER')     ?: 'NOT SET';
$pass = getenv('MYSQLPASSWORD') ?: '';

$pdo_test = null;
if (extension_loaded('pdo_mysql')) {
    try {
        $dsn = "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4";
        new PDO($dsn, $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $pdo_test = 'OK';
    } catch (Exception $e) {
        $pdo_test = $e->getMessage();
    }
}

echo json_encode([
    'php'       => PHP_VERSION,
    'pdo_mysql' => extension_loaded('pdo_mysql'),
    'host'      => $host,
    'port'      => $port,
    'db'        => $db,
    'user'      => $user,
    'pass_set'  => $pass !== '' ? 'YES' : 'NO',
    'connect'   => $pdo_test,
], JSON_PRETTY_PRINT);
