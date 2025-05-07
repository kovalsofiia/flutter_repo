import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_routes/models/student.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  _MyStudentsPageState createState() => _MyStudentsPageState();
}

class _MyStudentsPageState extends State<StudentsPage> {
  List<Student> _students = [];
  String _title = "Hello! This text is title, located inside Statefull widget.";

  @override
  void initState() {
    super.initState();
    readJson();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString(
      'assets/data/students.json',
    );
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
      body: Column(
        children: [
          if (_students.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: Image.asset("assets/images/myFlower.jpg"),
                      title: Text(student.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.course),
                          Text(student.averageScore),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Center(child: Text("No data loaded.")),
        ],
      ),
    );
  }
}
