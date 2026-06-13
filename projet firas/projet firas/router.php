<?php
// EduPlatform – PHP Router Configuration
// Required when using PHP built-in server (php -S localhost:3000)
$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Serve real static files directly (CSS, JS, uploads, etc.)
if ($uri !== '/' && file_exists(__DIR__ . $uri)) {
    return false;
}

// Route to correct PHP file
$file = __DIR__ . $uri;
if (file_exists($file . '.php')) {
    require $file . '.php';
} elseif (file_exists($file . '/index.php')) {
    require $file . '/index.php';
} else {
    require __DIR__ . '/index.php';
}
