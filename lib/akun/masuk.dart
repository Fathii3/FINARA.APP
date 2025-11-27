import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'daftar.dart';
import '../main.dart';

class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  // CONTROLLER
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // STATE
  bool passwordObscure = true;
  bool isLoading = false;

  //ip address
  final String urlLogin = 'http://192.168.1.7/money_api/masuk_akun.php';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // FUNGSI TAMPILAN NOTIFIKASI
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
        behavior: SnackBarBehavior.floating, // Membuatnya melayang
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showCustomSnackBar("Email dan Password harus diisi!", true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(urlLogin),
        body: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['value'] == 1) {
        // Simpan Sesi Login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLogin', true);
        await prefs.setString('id', data['id']);
        await prefs.setString('name', data['name']);
        await prefs.setString('email', data['email']);

        if (!mounted) return;

        // Tampilkan Sukses
        _showCustomSnackBar("Login Berhasil! Selamat datang.", false);

        // Pindah ke Halaman Utama
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Delay sedikit agar snackbar terlihat
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        if (!mounted) return;
        _showCustomSnackBar(data['message'] ?? "Gagal Login", true);
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        _showCustomSnackBar(
          "Gagal terhubung ke server. Cek koneksi internet.",
          true,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE2CDFC), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // DEKORASI BUBBLE
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
                        "Selamat Datang",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Masuk untuk mengelola keuanganmu",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 32),

                      // INPUT EMAIL
                      _buildTextField(
                        controller: emailController,
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // INPUT PASSWORD
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

                      // Lupa Sandi
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showCustomSnackBar(
                              "Fitur reset sandi belum tersedia",
                              true,
                            );
                          },
                          child: const Text(
                            "Lupa Sandi?",
                            style: TextStyle(
                              color: Color(0xFF226EC0),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // TOMBOL MASUK
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _loginUser,
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
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // NAVIGASI KE DAFTAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Daftar",
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

  // --- WIDGET HELPER (Sama persis dengan DaftarPage) ---
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
        // Efek bayangan halus
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
