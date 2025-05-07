import 'package:flutter/material.dart';

// сторінка перегляду однієї людини
class Person extends StatelessWidget {
  const Person({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final person =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Person : ${person?['name'] ?? 'Немає імені'} '),
      ),
      body: Column(
        children: [
          Text(person?['name'] ?? 'Немає імені'),
          Text('Age:${person?['age']?.toString() ?? 'Немає віку'}'),
        ],
      ),
    );
  }
}
