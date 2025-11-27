<?php
include 'koneksi.php';

// Tambahkan header agar dianggap JSON valid
header('Content-Type: application/json');

// Ambil data dari POST
$id = isset($_POST['id']) ? $_POST['id'] : '';
$name = isset($_POST['name']) ? $_POST['name'] : '';
$email = isset($_POST['email']) ? $_POST['email'] : '';

// Cek apakah password dikirim dari Flutter
$password = isset($_POST['password']) ? $_POST['password'] : '';

$response = array();

if (empty($id) || empty($name) || empty($email)) {
    $response['value'] = 0;
    $response['message'] = "Data tidak lengkap";
    echo json_encode($response);
    exit;
}

if (!empty($password)) {
    // Jika password diisi, enkripsi lalu update
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    $query = "UPDATE users SET name='$name', email='$email', password='$hashed_password' WHERE id='$id'";
} else {
    // Jika password kosong, hanya update nama dan email
    $query = "UPDATE users SET name='$name', email='$email' WHERE id='$id'";
}

// PERBAIKAN DI SINI: Gunakan $connect (bukan $koneksi) sesuai file koneksi.php
if (mysqli_query($connect, $query)) {
    $response['value'] = 1;
    $response['message'] = "Profil berhasil diperbarui";
} else {
    $response['value'] = 0;
    $response['message'] = "Gagal: " . mysqli_error($connect);
}

echo json_encode($response);
?>