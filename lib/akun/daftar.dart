import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // CONTROLLER INPUT
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // STATE
  bool passwordObscure = true;
  bool isChecked = false; // Checkbox Syarat & Ketentuan
  bool isLoading = false; // Status loading

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // FUNGSI TAMPILAN
  void _showCustomSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // FUNGSI REGISTER KE DATABASE
  Future<void> _registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validasi Input Kosong
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showCustomSnackBar("Semua kolom harus diisi!", true);
      return;
    }

    // Validasi Checkbox
    if (!isChecked) {
      _showCustomSnackBar("Anda harus menyetujui Syarat & Ketentuan.", true);
      return;
    }

    setState(() {
      isLoading = true; // Mulai loading
    });

    try {
      // ip address
      String url = "http://192.168.1.7/money_api/daftar_akun.php";

      final response = await http.post(
        Uri.parse(url),
        body: {"nama": name, "email": email, "password": password},
      );

      // Cek jika server merespon
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int value = data['value'] ?? 0;
        String message = data['message'] ?? "Terjadi kesalahan";

        if (value == 1) {
          // SUKSES DAFTAR
          if (!mounted) return;
          _showCustomSnackBar(message, false); // Tampilkan sukses (Hijau)
          await Future.delayed(const Duration(milliseconds: 1500));

          if (!mounted) return;
          Navigator.pop(context); // Kembali ke halaman Login
        } else {
          // GAGAL (Misal: Email sudah ada)
          if (!mounted) return;
          _showCustomSnackBar(message, true); // Tampilkan error (Merah)
        }
      } else {
        throw Exception("Error Server: ${response.statusCode}");
      }
    } catch (e) {
      // ERROR KONEKSI
      if (!mounted) return;
      debugPrint("Error Register: $e");
      _showCustomSnackBar("Gagal terhubung: Cek koneksi internet", true);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Selesai loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // 1. BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE2CDFC), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // 2. DEKORASI BUBBLE
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
                        height: 150,
                        child: Image.asset(
                          'assets/logo_namaapp.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                Text(
                                  "Logo tidak ditemukan",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            );
                          },
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

                      // INPUT NAMA LENGKAP
                      _buildTextField(
                        controller: nameController,
                        hint: "Nama Lengkap",
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),

                      // INPUT EMAIL
                      _buildTextField(
                        controller: emailController,
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // INPUT KATA SANDI
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
                              padding: const EdgeInsets.only(top: 4),
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
                          // Tombol aktif jika tidak loading
                          onPressed: isLoading ? null : _registerUser,
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

                      // BAGIAN NAVIGASI KEMBALI KE LOGIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Kembali ke Login
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

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
