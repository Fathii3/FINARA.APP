<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
include 'koneksi.php';

$id = $_POST['id'];

$sql = "DELETE FROM tujuan WHERE id = $id";

if ($connect->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $connect->error]);
}
?>