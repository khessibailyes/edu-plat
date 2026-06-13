<?php
require __DIR__ . '/config/db.php';
$pdo = get_pdo();

$accounts = [
    ['email' => 'admin@gmail.com',              'password' => 'Admin123!'],
    ['email' => 'admin@edu.local',              'password' => 'Admin123!'],
    ['email' => 'khessibailyes33@gmail.com',    'password' => 'Admin123!'],
    ['email' => 'btpinformatique8@gmail.com',   'password' => 'Student123!'],
    ['email' => 'firasbenhassine39@gmail.com',  'password' => 'Student123!'],
    ['email' => 'imen@gmail.com',               'password' => 'Teacher123!'],
];

$stmt = $pdo->prepare('UPDATE users SET password = ? WHERE email = ?');
foreach ($accounts as $a) {
    $hash = password_hash($a['password'], PASSWORD_BCRYPT);
    $stmt->execute([$hash, $a['email']]);
    if ($stmt->rowCount()) {
        echo 'OK  ' . $a['email'] . '  →  ' . $a['password'] . PHP_EOL;
    }
}
