import 'package:flutter/material.dart';
import 'FirstScreen.dart';
import 'SecondScreen.dart';
import 'ExtractArgumentsScreen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app
      // starts on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating "/" route - build FirstScreen widget.
        '/': (context) => const FirstScreen(),
        // When navigating "/second" route - build SecondScreen widget.
        '/second': (context) => const SecondScreen(),
        ExtractArgumentsScreen.routeName:
            (context) => const ExtractArgumentsScreen(),
      },
    ),
  );
}
