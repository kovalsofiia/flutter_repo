import 'package:flutter/material.dart';
import 'package:complex_task/screens/students_page.dart';
import 'package:complex_task/screens/layout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stateless Widget Text Title',
      home: const LayoutPage(),
    );
  }
}
