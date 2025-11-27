import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddTransactionPage extends StatefulWidget {
  final Map? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = true;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final List<String> categories = [
    'Makanan',
    'Belanja',
    'Transportasi',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
  ];
  String? selectedCategory;
  String? amountError;
  bool _isSending = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _isEditMode = true;
      final t = widget.transaction!;

      isIncome = t['type'] == 'income';
      amountController.text = double.parse(
        t['amount'].toString(),
      ).toInt().toString();
      noteController.text = t['note'] ?? '';

      // Parse Tanggal & Waktu dari Database
      DateTime dbDate = DateTime.parse(t['date']);
      selectedDate = dbDate;
      selectedTime = TimeOfDay(hour: dbDate.hour, minute: dbDate.minute);

      if (categories.contains(t['category'])) {
        selectedCategory = t['category'];
      }
    }
  }

  Future<void> _submit() async {
    setState(() => amountError = null);
    final text = amountController.text.trim();

    if (text.isEmpty) {
      setState(() => amountError = 'Wajib diisi');
      return;
    }

    // Gabungkan Tanggal + Waktu menjadi format: YYYY-MM-DD HH:MM:SS
    final DateTime finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    String dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(finalDateTime);

    // ip address
    String baseUrl = 'http://192.168.1.7/money_api';
    var url = _isEditMode
        ? Uri.parse('$baseUrl/update_transaksi.php')
        : Uri.parse('$baseUrl/add_transaksi.php');

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        url,
        body: {
          if (_isEditMode) 'id': widget.transaction!['id'].toString(),
          'title': isIncome ? 'Pemasukan' : (selectedCategory ?? 'Pengeluaran'),
          'amount': text.replaceAll(',', '.'),
          'type': isIncome ? 'income' : 'expense',
          'category': isIncome ? 'Pemasukan' : selectedCategory ?? 'Lainnya',
          'note': noteController.text,
          'date': dateStr, // Kirim tanggal lengkap dengan jam
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // Fungsi Pilih Jam
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    // Format tampilan Tanggal dan Jam
    String dateDisplay = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(selectedDate);
    String timeDisplay = selectedTime.format(
      context,
    ); // Format jam lokal (conth 14:30)

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    _isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
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
                children: [
                  _buildTypeToggle(),
                  const SizedBox(height: 20),

                  // INPUT NOMINAL
                  _OutlinedBox(
                    child: Row(
                      children: [
                        const Text(
                          "Rp ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BARIS TANGGAL DAN JAM (SEJAJAR)
                  Row(
                    children: [
                      // PILIH TANGGAL
                      Expanded(
                        flex: 3,
                        child: _OutlinedBox(
                          onTap: _pickDate,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(dateDisplay),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // PILIH JAM
                      Expanded(
                        flex: 2,
                        child: _OutlinedBox(
                          onTap: _pickTime,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(timeDisplay),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!isIncome) ...[
                    _OutlinedBox(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        hint: const Text('Pilih Kategori'),
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategory = val),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _OutlinedBox(
                    child: TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Catatan...',
                        icon: Icon(Icons.edit_note),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIncome
                            ? const Color(0xFF8DD89F)
                            : const Color(0xFFE87F7F),
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
                              _isEditMode ? 'UPDATE' : 'SIMPAN',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isIncome = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color(0xFF8DD89F)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pemasukan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isIncome = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isIncome
                      ? const Color(0xFFE87F7F)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Pengeluaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !isIncome ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _OutlinedBox({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: child,
      ),
    );
  }
}
