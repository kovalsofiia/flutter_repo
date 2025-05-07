import 'package:flutter/material.dart';
import 'package:flutter_routes/pages/ListPage.dart';
import 'package:flutter_routes/pages/Person.dart';
import 'package:flutter_routes/pages/InputPage.dart';
import 'package:flutter_routes/HomePage.dart';
import 'package:flutter_routes/pages/StudentsPage.dart';
import 'package:flutter_routes/pages/ProductForm.dart';
import 'package:flutter_routes/products/viewAllPage.dart';
import 'package:flutter_routes/pages/inputTaskPage.dart';
import 'package:flutter_routes/students/pages/addPage.dart';
import 'package:flutter_routes/students/pages/viewAll.dart';

void main(List<String> args) {
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/list': (context) => ListPage(),
        '/person': (context) => const Person(),
        '/input': (context) => InputPage(),
        '/students': (context) => StudentsPage(),
        '/productForm': (context) => ProductForm(),
        '/products': (context) => ProductListPage(),
        '/22': (context) => InputTaskWidget(),
        '/stud': (context) => StudentsListPage(),
        '/stud/add': (context) => AddStudentPage(),
      },
    ),
  );
}
