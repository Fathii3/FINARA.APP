import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'edit_profil_page.dart';
import '../akun/masuk.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String id = "";
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Fungsi Ambil Data Profil (ID, Nama, Email)
  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? ""; // Ambil ID dari sesi login
      name = prefs.getString('name') ?? "Nama Pengguna";
      email = prefs.getString('email') ?? "email@contoh.com";
    });
  }

  // Fungsi Navigasi ke Edit Profil
  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilPage(idUser: id, currentName: name, currentEmail: email),
      ),
    );

    // Jika kembali membawa data baru, update tampilan & simpan ke sesi lokal
    if (result != null && result is Map<String, String>) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', result['name']!);
      await prefs.setString('email', result['email']!);

      _loadProfile(); // Refresh tampilan profil

      // Tampilkan Pop-up Sukses dari Atas
      if (mounted) {
        _showSuccessPopup("Profil berhasil diperbarui!");
      }
    }
  }

  // Fungsi Logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar Akun"),
        content: const Text("Apakah kamu yakin ingin keluar dari aplikasi?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Hapus Sesi Login
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Kembali ke Login
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MasukPage()),
                (route) => false,
              );
            },
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup(String message) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Posisi dari atas layar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: -100,
              end: 0,
            ), // Animasi slide dari atas (-100 ke 0)
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Berhasil!",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Tampilkan overlay
    Overlay.of(context).insert(overlayEntry);

    // Hilangkan overlay setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Stack(
        children: [
          // HEADER GRADASI
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Profil Saya",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // AVATAR (MENGGUNAKAN ICON BAWAAN FLUTTER)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tampilkan Data
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // MENU OPTIONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            "Edit Profil",
                            Icons.edit_rounded,
                            Colors.blue,
                            _navigateToEditProfile,
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),
                          _buildMenuItem(
                            "Pengaturan",
                            Icons.settings_rounded,
                            Colors.orange,
                            () {},
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),

                          // TOMBOL KELUAR
                          _buildMenuItem(
                            "Keluar",
                            Icons.logout_rounded,
                            Colors.red,
                            _handleLogout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
