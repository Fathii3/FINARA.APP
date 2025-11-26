import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ⚠️ PENTING: Ganti baris ini sesuai nama project-mu!
// Cek baris paling atas di file main.dart untuk melihat nama package-nya.
// Contoh: import 'package:money_tracker/main.dart';
import 'package:FINARA/main.dart';

void main() {
  testWidgets('Cek apakah aplikasi bisa dibuka', (WidgetTester tester) async {
    // 1. Build aplikasi kita.
    // Pastikan nama class ini SAMA dengan class utama di main.dart
    await tester.pumpWidget(const MoneyTrackerGroupApp());

    // 2. Tunggu sebentar (biar tampilan loading selesai jika ada)
    await tester.pumpAndSettle();

    // 3. Cek apakah Menu Bawah (Bottom Navigation) muncul
    // Kita cari tulisan 'Beranda' dan 'Grafik' karena ada di menu bawah
    expect(find.text('Beranda'), findsOneWidget); // Harus ketemu 1
    expect(find.text('Grafik'), findsOneWidget); // Harus ketemu 1

    // 4. Cek apakah Icon Home ada
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
