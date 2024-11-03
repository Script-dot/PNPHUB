<?php
// ตรวจสอบประเภทของเบราว์เซอร์จาก User-Agent
$userAgent = $_SERVER['HTTP_USER_AGENT'];
$browser = '';

if (strpos($userAgent, 'MSIE') !== false) {
    $browser = 'MSIE';
} elseif (strpos($userAgent, 'Trident') !== false) {
    $browser = 'Trident';
} elseif (strpos($userAgent, 'Firefox') !== false) {
    $browser = 'Firefox';
} elseif (strpos($userAgent, 'Chrome') !== false) {
    $browser = 'Chrome';
} elseif (strpos($userAgent, 'Opera Mini') !== false) {
    $browser = 'Opera Mini';
} elseif (strpos($userAgent, 'Opera') !== false) {
    $browser = 'Opera';
} elseif (strpos($userAgent, 'Safari') !== false) {
    $browser = 'Safari';
} elseif (strpos($userAgent, 'Mozilla') !== false) {
    $browser = 'Mozilla';
}

echo "\n" . $browser;

// บันทึกข้อมูลผู้ใช้งานลงในไฟล์ logs.txt
$protocol = $_SERVER['SERVER_PROTOCOL'];
$ip = $_SERVER['REMOTE_ADDR'];
$port = $_SERVER['REMOTE_PORT'];
$hostname = gethostbyaddr($ip);

$logData = "IP: $ip\nProtocol: $protocol\nPort: $port\nUser-Agent: $userAgent\nHostname: $hostname\n\n";
file_put_contents('logs.txt', $logData, FILE_APPEND);

// ตรวจสอบคีย์ใน Whitelist
$keys = ["Key-12", "key-34"];
$sub = $_GET["key"] ?? '';

echo in_array($sub, $keys, true) ? "Whitelisted" : "Not Whitelisted";
?>
