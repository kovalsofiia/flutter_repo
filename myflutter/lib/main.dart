import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:myflutter/pages/add_page.dart';
import 'package:myflutter/pages/edit_page.dart';
import 'package:myflutter/pages/view_page.dart';
import 'package:myflutter/pages/admin_page.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/pages/main_screen.dart';
import 'package:myflutter/pages/user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Додано для веб-платформ
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/admin': (context) => const AdminPage(),
        '/': (context) => const MainScreen(),
        '/add': (context) => const AddPage(),
        '/edit':
            (context) => EditPage(
              peak: ModalRoute.of(context)!.settings.arguments as Peak,
            ),
        '/view': (context) {
          final peak = ModalRoute.of(context)!.settings.arguments as Peak;
          return DetailPage(
            peak: peak,
            onLoginNeeded: () {
              // Припускаємо, що MainScreen керує вкладками
              Navigator.pushNamed(context, '/'); // Повернення до MainScreen
              // Або зміна вкладки вручну, якщо потрібно
            },
          );
        },
        '/user_page': (context) => const UserPage(),
      },
    ),
  );
}
