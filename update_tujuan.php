<?php
header("Access-Control-Allow-Origin: *");
include 'koneksi.php';

$id = $_POST['id'];
$nama = $_POST['nama'];
$target = $_POST['target'];
$awal = $_POST['awal'];
$icon = $_POST['icon'];

$sql = "UPDATE tujuan SET 
        nama_tujuan='$nama', target_dana='$target', 
        tabungan_sekarang='$awal', icon='$icon' 
        WHERE id=$id";

if ($connect->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $connect->error]);
}
?>