import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// ✅ PERBAIKAN IMPORT: Masuk ke folder 'akun'
import 'akun/masuk.dart';

import 'pages/beranda_page.dart';
import 'pages/grafik_page.dart';
import 'pages/tujuan_page.dart';
import 'pages/profil_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MoneyTrackerGroupApp());
}

class MoneyTrackerGroupApp extends StatelessWidget {
  const MoneyTrackerGroupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FINARA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6FBFF),
      ),
      home: const MasukPage(), // Ini memanggil dari folder akun/masuk_page.dart
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaPage(),
    const GrafikPage(),
    const TujuanPage(),
    const ProfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Grafik'),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_rounded),
            label: 'Tujuan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
