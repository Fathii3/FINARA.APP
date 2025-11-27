<?php
header("Access-Control-Allow-Origin: *");
include 'koneksi.php';

$id = $_POST['id'];
$title = $_POST['title'];
$amount = $_POST['amount'];
$type = $_POST['type'];
$category = $_POST['category'];
$note = $_POST['note'];
$date = $_POST['date'];

$sql = "UPDATE transaksi SET 
        title='$title', amount='$amount', type='$type', 
        category='$category', note='$note', date='$date' 
        WHERE id=$id";

if ($connect->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $connect->error]);
}
?>