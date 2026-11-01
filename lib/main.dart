import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/db_factory.dart';
import 'pages/sqlite_page.dart';
import 'pages/hive_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Agar SQLite bisa jalan di web / Windows / Linux
  initDatabaseFactory();

  await Hive.initFlutter();
  await Hive.openBox('contacts_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Kontak')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SqlitePage()),
              ),
              child: const Text('Kontak dengan SQLite'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HivePage()),
              ),
              child: const Text('Kontak dengan Hive'),
            ),
          ],
        ),
      ),
    );
  }
}
