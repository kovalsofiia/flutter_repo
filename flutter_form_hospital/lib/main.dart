import 'package:flutter/material.dart';
import 'package:flutter_form/pages/ListPage.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => ListPatientPage()},
    ),
  );
}
