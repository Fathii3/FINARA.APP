<?php
include 'koneksi.php';

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Ambil data user berdasarkan email
    $cek = mysqli_query($connect, "SELECT * FROM users WHERE email = '$email'");
    $row = mysqli_fetch_array($cek);

    if (mysqli_num_rows($cek) > 0) {
        // Verifikasi password hash
        if (password_verify($password, $row['password'])) {
            $response['value'] = 1;
            $response['message'] = "Login Berhasil";
            // Kirim data user ke Flutter untuk disimpan
            $response['id'] = $row['id'];
            $response['name'] = $row['name'];
            $response['email'] = $row['email'];
        } else {
            $response['value'] = 0;
            $response['message'] = "Password salah";
        }
    } else {
        $response['value'] = 0;
        $response['message'] = "Email tidak ditemukan";
    }
}

echo json_encode($response);
?>