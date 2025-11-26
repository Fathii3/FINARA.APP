import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahTujuanPage extends StatefulWidget {
  final Map? goal;

  const TambahTujuanPage({super.key, this.goal});

  @override
  State<TambahTujuanPage> createState() => _TambahTujuanPageState();
}

class _TambahTujuanPageState extends State<TambahTujuanPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _awalController = TextEditingController();

  bool _isSending = false;
  bool _isEditMode = false;
  int _selectedIconIndex = 0;

  final List<Map<String, dynamic>> _icons = [
    {'icon': Icons.laptop_mac, 'name': 'laptop'},
    {'icon': Icons.directions_car, 'name': 'car'},
    {'icon': Icons.home, 'name': 'home'},
    {'icon': Icons.flight, 'name': 'travel'},
    {'icon': Icons.school, 'name': 'education'},
    {'icon': Icons.savings, 'name': 'savings'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _isEditMode = true;
      final g = widget.goal!;

      _namaController.text = g['nama_tujuan'];
      _targetController.text = double.parse(
        g['target_dana'].toString(),
      ).toInt().toString();
      _awalController.text = double.parse(
        g['tabungan_sekarang'].toString(),
      ).toInt().toString();

      int iconIndex = _icons.indexWhere(
        (element) => element['name'] == g['icon'],
      );
      if (iconIndex != -1) {
        _selectedIconIndex = iconIndex;
      }
    }
  }

  Future<void> _simpanData() async {
    // Validasi Input Kosong
    if (_namaController.text.isEmpty || _targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Target Dana wajib diisi!")),
      );
      return;
    }

    setState(() => _isSending = true);

    // ⚠️ GANTI IP ADDRESS SESUAI LAPTOP KAMU
    String baseUrl = 'http://10.151.175.231/money_api';
    var url = _isEditMode
        ? Uri.parse('$baseUrl/update_tujuan.php')
        : Uri.parse('$baseUrl/add_tujuan.php');

    try {
      final response = await http.post(
        url,
        body: {
          if (_isEditMode) 'id': widget.goal!['id'].toString(),
          'nama': _namaController.text,
          'target': _targetController.text,
          'awal': _awalController.text.isEmpty ? '0' : _awalController.text,
          'icon': _icons[_selectedIconIndex]['name'],
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // ✅ BERHASIL DISIMPAN
        // Kita HAPUS SnackBar di sini.
        // Cukup tutup halaman dan kirim nilai 'true' ke halaman TujuanPage.
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    _isEditMode
                        ? 'Edit Target Tabungan'
                        : 'Target Tabungan Baru',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Tujuan"),
                  _buildTextField(
                    controller: _namaController,
                    hint: "Contoh: Beli iPhone 15",
                    icon: Icons.flag,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Target Dana (Rp)"),
                  _buildTextField(
                    controller: _targetController,
                    hint: "0",
                    icon: Icons.monetization_on_outlined,
                    isNumber: true,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Tabungan Awal / Terkumpul"),
                  _buildTextField(
                    controller: _awalController,
                    hint: "0",
                    icon: Icons.account_balance_wallet_outlined,
                    isNumber: true,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Pilih Ikon"),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 15),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIconIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedIconIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (!isSelected)
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Icon(
                              _icons[index]['icon'],
                              color: isSelected ? Colors.white : Colors.grey,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditMode ? "UPDATE DATA" : "MULAI NABUNG",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          icon: Icon(icon, color: Colors.blue.shade300),
        ),
      ),
    );
  }
}
