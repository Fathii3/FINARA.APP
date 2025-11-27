<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include 'koneksi.php';

$title = $_POST['title'];
$amount = $_POST['amount'];
$type = $_POST['type']; // 'income' atau 'expense'
$category = $_POST['category'];
$note = $_POST['note'];
$date = $_POST['date']; // Format YYYY-MM-DD

$sql = "INSERT INTO transaksi (title, amount, type, category, note, date) 
        VALUES ('$title', '$amount', '$type', '$category', '$note', '$date')";

if ($connect->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Berhasil disimpan"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal: " . $sql]);
}
?>