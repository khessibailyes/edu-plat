<?php
// Minimal JWT encode/decode (HS256)
declare(strict_types=1);
function base64url_encode(string $data): string
{
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64url_decode(string $data): string
{
    $pad = 4 - (strlen($data) % 4);
    if ($pad < 4) {
        $data .= str_repeat('=', $pad);
    }
    return base64_decode(strtr($data, '-_', '+/'));
}

function jwt_encode(array $payload, string $secret, int $expSeconds = 86400): string
{
    $header = ['alg' => 'HS256', 'typ' => 'JWT'];
    $payload['iat'] = time();
    $payload['exp'] = time() + $expSeconds;

    $segments = [];
    $segments[] = base64url_encode(json_encode($header));
    $segments[] = base64url_encode(json_encode($payload));
    $signing_input = implode('.', $segments);
    $sig = hash_hmac('sha256', $signing_input, $secret, true);
    $segments[] = base64url_encode($sig);
    return implode('.', $segments);
}

function jwt_decode(string $jwt, string $secret): array
{
    $parts = explode('.', $jwt);
    if (count($parts) !== 3) {
        throw new RuntimeException('Invalid token structure');
    }
    [$h, $p, $s] = $parts;
    $header = json_decode(base64url_decode($h), true);
    $payload = json_decode(base64url_decode($p), true);
    $sig = base64url_decode($s);

    $verify = hash_hmac('sha256', "$h.$p", $secret, true);
    if (!hash_equals($verify, $sig)) {
        throw new RuntimeException('Invalid token signature');
    }
    if (!empty($payload['exp']) && time() > (int)$payload['exp']) {
        throw new RuntimeException('Token expired');
    }
    return $payload;
}
