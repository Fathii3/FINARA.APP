import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'tambah_transaksi_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List _listData = [];
  bool _isLoading = true;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _totalSaldo = 0;

  // ⚠️ GANTI IP ADDRESS SESUAI DENGAN LAPTOP KAMU
  final String baseUrl = 'http://10.151.175.231/money_api';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_transaksi.php'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        // LOGIC SORTING
        data.sort((a, b) {
          DateTime dateA =
              DateTime.tryParse(a['date'].toString()) ?? DateTime.now();
          DateTime dateB =
              DateTime.tryParse(b['date'].toString()) ?? DateTime.now();
          int compareDate = dateB.compareTo(dateA);

          if (compareDate != 0) {
            return compareDate;
          } else {
            int idA = int.parse(a['id'].toString());
            int idB = int.parse(b['id'].toString());
            return idB.compareTo(idA);
          }
        });

        if (mounted) {
          setState(() {
            _listData = data;
            _isLoading = false;
            _hitungSaldo();
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_transaksi.php'),
        body: {'id': id},
      );
      if (response.statusCode == 200) {
        setState(() {
          _listData.removeWhere((item) => item['id'].toString() == id);
          _hitungSaldo();
        });
        _getData();
        _showSuccessPopup("Data berhasil dihapus");
      }
    } catch (e) {
      debugPrint('Error delete: $e');
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Transaksi?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteData(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _hitungSaldo() {
    double masuk = 0;
    double keluar = 0;
    for (var item in _listData) {
      double amount = double.parse(item['amount'].toString());
      if (item['type'] == 'income') {
        masuk += amount;
      } else {
        keluar += amount;
      }
    }
    setState(() {
      _totalPemasukan = masuk;
      _totalPengeluaran = keluar;
      _totalSaldo = masuk - keluar;
    });
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  IconData _getIconByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'transportasi':
        return Icons.motorcycle_rounded;
      case 'hiburan':
        return Icons.movie_rounded;
      case 'kesehatan':
        return Icons.local_hospital_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  void _showSuccessPopup(String message) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
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

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Stack(
        children: [
          // 1. BACKGROUND HEADER BIRU
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
          ),

          // 🔥 TOMBOL REFRESH HEADER SUDAH DIHAPUS 🔥

          // 2. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 10),
                _buildBalanceCard(),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Transaksi Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Tombol refresh list juga sudah dihapus
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _listData.isEmpty
                      ? Center(
                          child: Text(
                            "Belum ada transaksi",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _getData, // Tarik ke bawah untuk refresh
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                            itemCount: _listData.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _buildTransactionItem(_listData[index]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionPage(),
          );
          if (result == true) {
            _getData();
            _showSuccessPopup("Data transaksi berhasil disimpan.");
          }
        },
        backgroundColor: const Color(0xFF0288D1),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/pp.jpeg'),
            child: null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Halo, Ririn! 👋',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Saldo', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 5),
          Text(
            _formatRupiah(_totalSaldo),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_circle_up_rounded,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pemasukan",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          _formatRupiah(_totalPemasukan),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_circle_down_rounded,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pengeluaran",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          _formatRupiah(_totalPengeluaran),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map item) {
    bool isIncome = item['type'] == 'income';
    double amount = double.parse(item['amount'].toString());
    DateTime date =
        DateTime.tryParse(item['date'].toString()) ?? DateTime.now();
    String dateStr = DateFormat('dd MMM, HH:mm', 'id_ID').format(date);
    String note = item['note'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTransactionPage(transaction: item),
          );
          if (result == true) {
            _getData();
            _showSuccessPopup("Data transaksi berhasil diperbarui.");
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconByCategory(item['category'] ?? ''),
                color: isIncome ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (note.isNotEmpty) ...[
                        const Text(
                          " • ",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Expanded(
                          child: Text(
                            note,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (isIncome ? '+ ' : '- ') + _formatRupiah(amount),
                  style: TextStyle(
                    color: isIncome ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _showDeleteDialog(item['id'].toString()),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
