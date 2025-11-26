import 'dart:convert'; // 1. IMPORT UNTUK JSON
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 2. IMPORT PAKET HTTP

// Import ini opsional karena kita hanya melakukan pop,
// tapi bagus untuk referensi jika dibutuhkan/konsistensi.
import 'masuk.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // --- CONTROLLER INPUT ---
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // --- STATE ---
  bool passwordObscure = true;
  bool isChecked = false;
  bool isLoading = false; // Status loading agar tombol tidak ditekan 2x

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar hemat memori
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI REGISTER KE DATABASE ---
  Future<void> _registerUser() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    // Validasi Input Kosong
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom harus diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true; // Mulai loading
    });

    try {
      // ⚠️ GANTI IP INI SESUAI PERANGKAT ANDA:
      // Emulator Android: 10.0.2.2
      // HP Fisik / iOS: Gunakan IP Laptop (contoh: 192.168.1.5)
      String url = "http://10.0.2.2/api_uang/register.php";

      final response = await http.post(
        Uri.parse(url),
        body: {"name": name, "email": email, "password": password},
      );

      final data = jsonDecode(response.body);
      int value = data['value'];
      String message = data['message'];

      if (value == 1) {
        // --- BERHASIL DAFTAR ---
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        // Kembali ke halaman login setelah berhasil
        Navigator.pop(context);
      } else {
        // --- GAGAL (Misal: Email sudah ada) ---
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // --- ERROR KONEKSI ---
      if (!mounted) return;
      print("Error: $e"); // Untuk debugging di console
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal terhubung ke server. Cek koneksi internet/IP."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Selesai loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan resizeToAvoidBottomInset agar keyboard tidak menutupi input
      resizeToAvoidBottomInset: true,
      body: Container(
        // 1. BACKGROUND GRADIENT (Konsisten dengan MasukPage)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE2CDFC), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // 2. DEKORASI BUBBLE (Latar Belakang)
            Positioned(top: -60, right: -60, child: _bubble(200)),
            Positioned(bottom: -80, left: -40, child: _bubble(240)),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO APLIKASI
                      SizedBox(
                        height: 80,
                        child: Image.asset(
                          'assets/logo_app.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.account_balance_wallet,
                                size: 60,
                                color: Colors.blue,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // JUDUL HALAMAN
                      const Text(
                        "Buat Akun Baru",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Isi data diri untuk mulai menabung",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 32),

                      // --- FORM DAFTAR ---

                      // 1. INPUT NAMA LENGKAP
                      _buildTextField(
                        controller: nameController,
                        hint: "Nama Lengkap",
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),

                      // 2. INPUT EMAIL
                      _buildTextField(
                        controller: emailController,
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // 3. INPUT KATA SANDI
                      _buildTextField(
                        controller: passwordController,
                        hint: "Kata Sandi",
                        icon: Icons.lock_outline_rounded,
                        obscureText: passwordObscure,
                        trailing: IconButton(
                          icon: Icon(
                            passwordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordObscure = !passwordObscure;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CHECKBOX SYARAT & KETENTUAN
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFF226EC0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  isChecked = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                              ), // Supaya sejajar dengan checkbox
                              child: Text(
                                "Saya menyetujui Syarat & Ketentuan Penggunaan Aplikasi.",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // TOMBOL DAFTAR
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          // Jika checkbox dicentang DAN tidak sedang loading, tombol aktif
                          onPressed: (isChecked && !isLoading)
                              ? _registerUser // Panggil fungsi register
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF226EC0),
                            disabledBackgroundColor: Colors.blue.withOpacity(
                              0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Daftar Akun",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- BAGIAN NAVIGASI KEMBALI KE LOGIN ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Kembali ke MasukPage (Login)
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF226EC0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Efek bayangan halus agar field terlihat timbul
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF226EC0).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF226EC0), size: 22),
          suffixIcon: trailing,
          border: InputBorder.none, // Hilangkan border bawaan TextField
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  // Widget Bubble Background
  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
