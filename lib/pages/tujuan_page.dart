import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'tambah_tujuan_page.dart';

class TujuanPage extends StatefulWidget {
  const TujuanPage({super.key});

  @override
  State<TujuanPage> createState() => _TujuanPageState();
}

class _TujuanPageState extends State<TujuanPage> {
  List _listGoals = [];
  bool _isLoading = true;
  final String baseUrl = 'http://10.151.175.231/money_api';

  @override
  void initState() {
    super.initState();
    _getGoals();
  }

  Future<void> _getGoals() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_tujuan.php'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _listGoals = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGoal(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_tujuan.php'),
        body: {'id': id},
      );
      if (response.statusCode == 200) {
        _getGoals();
        // 🔥 HANYA PAKAI POPUP ATAS (SnackBar dihapus) 🔥
        if (mounted) {
          _showSuccessPopup("Tujuan berhasil dihapus");
        }
      }
    } catch (e) {
      debugPrint("Error delete: $e");
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Tujuan?"),
        content: const Text("Data tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGoal(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getIconByName(String name) {
    switch (name) {
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // ============================================================
  // 🔥 FUNGSI POPUP NOTIFIKASI ATAS 🔥
  // ============================================================
  void _showSuccessPopup(String message) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Posisi di Atas
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100, end: 0),
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
                    color: const Color(0xFF43A047), // Hijau
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

    Overlay.of(context).insert(overlayEntry);
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
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Impian & Target",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Icon(Icons.star_rounded, color: Colors.white38, size: 30),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  "Goal Nabungmu",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // FLOATING CARD "TAMBAH BARU"
          Positioned(
            top: 180,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TambahTujuanPage(),
                );
                // 🔥 JIKA BERHASIL BUAT, TAMPILKAN POPUP ATAS 🔥
                if (result == true) {
                  _getGoals();
                  _showSuccessPopup("Target tabungan berhasil dibuat!");
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Buat Tujuan Baru",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LIST GOALS
          Padding(
            padding: const EdgeInsets.only(top: 260),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _listGoals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada target",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _getGoals,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: _listGoals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = _listGoals[index];
                        double target = double.parse(
                          item['target_dana'].toString(),
                        );
                        double current = double.parse(
                          item['tabungan_sekarang'].toString(),
                        );
                        double progress = target == 0
                            ? 0
                            : (current / target).clamp(0.0, 1.0);
                        double sisa = target - current;
                        if (sisa < 0) sisa = 0;

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      _getIconByName(item['icon']),
                                      size: 28,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['nama_tujuan'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "Kurang ${_formatRupiah(sisa)}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _showDeleteDialog(
                                      item['id'].toString(),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red[300],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      final result = await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            TambahTujuanPage(goal: item),
                                      );
                                      // 🔥 JIKA BERHASIL EDIT, TAMPILKAN POPUP ATAS 🔥
                                      if (result == true) {
                                        _getGoals();
                                        _showSuccessPopup(
                                          "Target berhasil diperbarui!",
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[100],
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.blue[400],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${(progress * 100).toInt()}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatRupiah(target),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
