<?php
// ============================================================
//  config/db.php  –  PDO Database Connection (Singleton)
// ============================================================
declare(strict_types=1);

define('DB_HOST', '127.0.0.1');
define('DB_PORT', '3306');
define('DB_NAME', 'edu_platform');
define('DB_USER', 'root');
define('DB_PASS', '');          // Change if your MySQL root has a password
define('DB_CHARSET', 'utf8mb4');

function get_pdo(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=%s',
            DB_HOST, DB_PORT, DB_NAME, DB_CHARSET
        );
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            // Never expose connection details to the browser
            error_log('DB connection failed: ' . $e->getMessage());
            http_response_code(503);
            die('Service temporarily unavailable. Please try again later.');
        }
    }
    return $pdo;
}
