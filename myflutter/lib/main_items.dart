import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myflutter/module/models/item.dart';
import 'package:myflutter/module/pages/add_item.dart';
import 'package:myflutter/module/pages/edit_item.dart';
import 'package:myflutter/module/pages/view_item.dart';
import 'package:myflutter/module/pages/view_items.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
              item: ModalRoute.of(context)!.settings.arguments as Item,
            ),
        '/view':
            (context) => DetailPage(
              item: ModalRoute.of(context)!.settings.arguments as Item,
            ),
      },
    ),
  );
}
