import 'package:flutter/material.dart';

class InputTaskWidget extends StatefulWidget {
  const InputTaskWidget({super.key});

  @override
  State<InputTaskWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<InputTaskWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input task page')),
      body: Column(children: [Text("Text")]),
    );
  }
}
