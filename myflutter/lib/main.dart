import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:myflutter/pages/home_page.dart';
import 'package:myflutter/pages/add_page.dart';
import 'package:myflutter/pages/edit_page.dart';
import 'package:myflutter/pages/view_page.dart';
import 'package:myflutter/models/peak.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Додано для веб-платформ
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/add': (context) => const AddPage(),
        '/edit':
            (context) => EditPage(
              peak: ModalRoute.of(context)!.settings.arguments as Peak,
            ),
        '/view':
            (context) => DetailPage(
              peak: ModalRoute.of(context)!.settings.arguments as Peak,
            ),
      },
    ),
  );
}
