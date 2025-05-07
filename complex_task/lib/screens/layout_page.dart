import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:complex_task/models/student.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  _MyStudentsPageState createState() => _MyStudentsPageState();
}

class _MyStudentsPageState extends State<LayoutPage> {
  List<Student> _students = [];
  String _title = "Hello! This text is title, located inside Statefull widget.";

  @override
  void initState() {
    super.initState();
    readJson();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/students.json');
    final data = await json.decode(response);
    setState(() {
      _title = data["title"];
      _students =
          (data["items"] as List)
              .map((item) => Student.fromJson(item))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(_title)),
      body:
          _students.isNotEmpty
              ? Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.asset("assets/student.jpg", height: 50),
                                const SizedBox(height: 4),
                                Text(student.name),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Image.asset("assets/student.jpg", height: 50),
                                const SizedBox(width: 8),
                                Text(student.name),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Image.asset("assets/student.jpg", height: 50),
                                const SizedBox(width: 8),
                                Text(student.name),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: Text("No info")),
    );
  }
}
