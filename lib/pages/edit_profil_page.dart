import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilPage extends StatefulWidget {
  final String idUser;
  final String currentName;
  final String currentEmail;

  const EditProfilPage({
    super.key,
    required this.idUser,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController =
      TextEditingController(); // Opsional ganti password

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  // Update controller jika widget parent mengirim data baru
  @override
  void didUpdateWidget(covariant EditProfilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentName != oldWidget.currentName) {
      _nameController.text = widget.currentName;
    }
    if (widget.currentEmail != oldWidget.currentEmail) {
      _emailController.text = widget.currentEmail;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Update ke Database
  Future<void> _updateProfile() async {
    // Trim untuk menghapus spasi berlebih
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Email tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ip address
      String url = "http://192.168.1.7/money_api/update_user.php";

      // Siapkan data yang mau dikirim
      Map<String, String> body = {
        "id": widget.idUser,
        "name": name,
        "email": email,
      };

      // Hanya kirim password jika diisi
      if (password.isNotEmpty) {
        body["password"] = password;
      }

      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Cek value dari respons PHP (biasanya 1 = sukses)
        if (data['value'] == 1) {
          if (!mounted) return;

          // Tutup halaman dan kirim data balik ke ProfilPage agar tampilan terupdate
          Navigator.pop(context, {'name': name, 'email': email});
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal update: ${data['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Gagal terhubung ke server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error Update: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan koneksi. Cek server/internet."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField("Nama Lengkap", _nameController, Icons.person),
            const SizedBox(height: 20),
            _buildTextField("Email Address", _emailController, Icons.email),
            const SizedBox(height: 20),

            // Field Password Baru (Opsional)
            _buildTextField(
              "Password Baru (Opsional)",
              _passwordController,
              Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            const Text(
              "Kosongkan password jika tidak ingin menggantinya.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            // enabled: true, Secara default true, tapi pastikan tidak false
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.blueAccent),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
