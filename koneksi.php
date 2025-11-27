<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "money_tracker_db";

$connect = new mysqli($host, $user, $pass, $db);

if ($connect->connect_error) {
    die("Koneksi Gagal: " . $connect->connect_error);
}
?>