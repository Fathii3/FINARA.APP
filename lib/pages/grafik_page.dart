import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GrafikPage extends StatefulWidget {
  const GrafikPage({super.key});

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

class _GrafikPageState extends State<GrafikPage> {
  DateTime _selectedDate = DateTime.now();
  List _allTransactions = [];
  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<String, double> _expenseCategories = {};

  final Map<String, Color> categoryColors = {
    'Makanan': const Color(0xFFFF7043),
    'Belanja': const Color(0xFF42A5F5),
    'Transportasi': const Color(0xFF66BB6A),
    'Hiburan': const Color(0xFFAB47BC),
    'Kesehatan': const Color(0xFF26C6DA),
    'Pendidikan': const Color(0xFFFFCA28),
    'Lainnya': const Color(0xFFBDBDBD),
  };

  Color _getCategoryColor(String category) =>
      categoryColors[category] ?? const Color(0xFFBDBDBD);

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
        return Icons.category_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    // ⚠️ GANTI IP ADDRESS SESUAI DENGAN LAPTOP KAMU
    var url = Uri.parse('http://10.151.175.231/money_api/get_transaksi.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _allTransactions = jsonDecode(response.body);
            _isLoading = false;
            _calculateData();
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateData() {
    double income = 0;
    double expense = 0;
    Map<String, double> categories = {};

    for (var item in _allTransactions) {
      DateTime date = DateTime.parse(item['date']);
      if (date.month == _selectedDate.month &&
          date.year == _selectedDate.year) {
        double amount = double.parse(item['amount'].toString());
        if (item['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
          String catName = item['category'] ?? 'Lainnya';
          categories[catName] = (categories[catName] ?? 0) + amount;
        }
      }
    }
    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _expenseCategories = categories;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
      );
      _calculateData();
    });
  }

  String _formatRupiah(double number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. HEADER TITLE & MONTH NAVIGATOR (Fixed)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 15),
                  child: const Text(
                    'Laporan Keuangan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. BODY CONTENT
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          // Ganti SingleChildScrollView dengan Column
                          children: [
                            // --- BAGIAN ATAS (FIXED / TIDAK SCROLL) ---
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  // OVERVIEW CARD
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Pemasukan",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                _formatRupiah(_totalIncome),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 30,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Pengeluaran",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                _formatRupiah(_totalExpense),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  // CHART (TIDAK SCROLL, UKURAN DIPERKECIL SEDIKIT)
                                  Container(
                                    height: 220, // Tinggi tetap untuk chart
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: _totalExpense == 0
                                        ? const Center(
                                            child: Text(
                                              "Belum ada pengeluaran",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : PieChart(
                                            PieChartData(
                                              sections: _expenseCategories.entries.map((
                                                e,
                                              ) {
                                                return PieChartSectionData(
                                                  color: _getCategoryColor(
                                                    e.key,
                                                  ),
                                                  value: e.value,
                                                  title:
                                                      '${(e.value / _totalExpense * 100).toStringAsFixed(0)}%',
                                                  radius:
                                                      50, // Radius sedikit dikecilkan agar muat
                                                  titleStyle: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }).toList(),
                                              centerSpaceRadius: 40,
                                              sectionsSpace: 2,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),

                            // --- BAGIAN BAWAH (SCROLLABLE) ---
                            const SizedBox(height: 15),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Detail Kategori",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // LISTVIEW HANYA DI SINI
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  20,
                                ),
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  ..._expenseCategories.entries.map((e) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(
                                                e.key,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              _getIconByCategory(e.key),
                                              color: _getCategoryColor(e.key),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              e.key,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatRupiah(e.value),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
