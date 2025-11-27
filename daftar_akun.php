<?php
include 'koneksi.php';

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nama = $_POST['nama'];
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Cek apakah email sudah ada
    $cekEmail = "SELECT * FROM users WHERE email = '$email'";
    $result = mysqli_query($connect, $cekEmail);

    if (mysqli_num_rows($result) > 0) {
        $response['value'] = 0;
        $response['message'] = "Email sudah terdaftar";
    } else {
        // Enkripsi password sebelum disimpan
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        
        $insert = "INSERT INTO users (name, email, password) VALUES ('$nama', '$email', '$hashed_password')";
        
        if (mysqli_query($connect, $insert)) {
            $response['value'] = 1;
            $response['message'] = "Berhasil mendaftar";
        } else {
            $response['value'] = 0;
            $response['message'] = "Gagal mendaftar";
        }
    }
} else {
    $response['value'] = 0;
    $response['message'] = "Metode request salah";
}

echo json_encode($response);
?>