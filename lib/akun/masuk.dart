import 'dart:convert'; // 1. IMPORT JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 2. IMPORT HTTP

// ✅ IMPORT NAVIGASI:
import 'daftar.dart'; // Ke halaman daftar (satu folder)
import '../main.dart'; // Ke halaman utama (folder luar)

class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  // --- CONTROLLER ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // --- STATE ---
  bool passwordObscure = true;
  bool isChecked = false; // Untuk "Ingat Saya"
  bool isLoading = false; // Status loading

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGIN KE DATABASE ---
  Future<void> _loginUser() async {
    final email = emailController.text;
    final password = passwordController.text;

    // Validasi Input
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan Kata Sandi harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true; // Mulai Loading
    });

    try {
      // ⚠️ GANTI IP INI SESUAI PERANGKAT ANDA:
      // Emulator Android: 10.0.2.2
      // HP Fisik / iOS: Gunakan IP Laptop (contoh: 192.168.1.5)
      String url = "http://10.0.2.2/api_uang/login.php";

      final response = await http.post(
        Uri.parse(url),
        body: {"email": email, "password": password},
      );

      final data = jsonDecode(response.body);
      int value = data['value'];
      String message = data['message'];

      if (value == 1) {
        // --- LOGIN BERHASIL ---
        // Anda bisa mengambil data user dari sini:
        // String namaUser = data['name'];
        // String idUser = data['id'];

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Berhasil!"),
            backgroundColor: Colors.green,
          ),
        );

        // Pindah ke Halaman Utama
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        // --- LOGIN GAGAL (Password/Email Salah) ---
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // --- ERROR KONEKSI ---
      if (!mounted) return;
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal terhubung ke server. Cek IP/Koneksi."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop Loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // 1. BACKGROUND GRADIENT (Sama dengan DaftarPage)
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
                    children: [
                      // LOGO
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

                      // JUDUL
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

                      // --- FORM MASUK ---

                      // 1. EMAIL
                      _buildTextField(
                        controller: emailController,
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // 2. PASSWORD
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
                      const SizedBox(height: 12),

                      // INGAT SAYA & LUPA SANDI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                              const Text(
                                "Ingat saya",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Logika Lupa Sandi (Opsional)
                            },
                            child: const Text(
                              "Lupa Sandi?",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF226EC0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // TOMBOL MASUK
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          // Jika Loading, tombol dimatikan sementara
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
                              // Pindah ke SignUpPage
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

  // --- WIDGET HELPER ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
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
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF226EC0), size: 22)
              : null,
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
