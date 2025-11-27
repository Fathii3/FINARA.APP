<?php
header("Access-Control-Allow-Origin: *");
include 'koneksi.php';

$sql = "SELECT * FROM tujuan ORDER BY created_at DESC";
$result = $connect->query($sql);

$data = array();
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>