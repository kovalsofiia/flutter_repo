import 'package:flutter/material.dart';
import 'package:flutter_form/pages/ListCarsPage.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: '/cars',
      routes: {'/cars': (context) => ListCarPage()},
    ),
  );
}
