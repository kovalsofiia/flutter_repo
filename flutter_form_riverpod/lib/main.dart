import 'package:flutter/material.dart';
import 'package:flutter_form/pages/ListPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // тут переписати із використанням провайдера
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/': (context) => ListPatientPage()},
      ),
    ),
  );
}
