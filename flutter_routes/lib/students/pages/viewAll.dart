import 'package:flutter/material.dart';
import 'package:flutter_routes/students/pages/addPage.dart';
import 'package:flutter_routes/students/pages/viewPage.dart';
import 'package:flutter_routes/students/student.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({Key? key}) : super(key: key);

  @override
  _StudentsListPageState createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  // список обєктів
  final List<Student> _students = [];

  // функція додавання обєкту
  void _addStudent(Student student) {
    setState(() {
      _students.add(student);
    });
  }

  // функція оновлення обєкту
  void _updateStudent(int index, Student updatedStudent) {
    setState(() {
      _students[index] = updatedStudent;
    });
  }

  // функція видалення обєкту
  void _deleteStudent(int index) {
    setState(() {
      _students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список студентів')),
      body:
          // перевіряємо чи не пустий список
          _students.isEmpty
              ? const Center(child: Text('Список порожній'))
              : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return ListTile(
                    title: Text(student.name),
                    subtitle: Text('Курс: ${student.course.toString()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteStudent(index),
                    ),
                    onTap: () {
                      // навігатор перехід
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StudentDetailPage(
                                student: student,
                                onDelete: () => _deleteStudent(index),
                                onEdit:
                                    (updatedStudent) =>
                                        _updateStudent(index, updatedStudent),
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
      // кнопочка додавання обєкту
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newStudent = await Navigator.push<Student>(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentPage()),
          );
          if (newStudent != null) {
            _addStudent(newStudent);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
