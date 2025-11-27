<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
include 'koneksi.php';

$nama = $_POST['nama'];
$target = $_POST['target'];
$awal = $_POST['awal']; // Tabungan awal (opsional)
$icon = $_POST['icon'];

// Pastikan 'awal' tidak kosong, kalau kosong set 0
if($awal == "") $awal = 0;

$sql = "INSERT INTO tujuan (nama_tujuan, target_dana, tabungan_sekarang, icon) 
        VALUES ('$nama', '$target', '$awal', '$icon')";

if ($connect->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $connect->error]);
}
?>