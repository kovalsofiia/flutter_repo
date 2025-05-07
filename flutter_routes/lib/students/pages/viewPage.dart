import 'package:flutter/material.dart';
import 'package:flutter_routes/students/pages/addPage.dart';
import 'package:flutter_routes/students/student.dart';

// стейтлес віджет, бо просто відображення
class StudentDetailPage extends StatelessWidget {
  // визначимо об'єкт
  final Student student;
  // функції видалення та редагування обєкту
  final VoidCallback onDelete;
  final ValueChanged<Student> onEdit;
  const StudentDetailPage({
    Key? key,
    required this.student,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Деталі студента')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ПІБ: ${student.name}', style: const TextStyle(fontSize: 18)),
            Text(
              'Курс: ${student.course.toString()}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Факультет: ${student.faculty}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Стипендія: ${student.scolarhip ? "Так" : "Ні"}',
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // передаємо у роутер обєкт
                    onPressed: () async {
                      final updatedStudent = await Navigator.push<Student>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddStudentPage(),
                        ),
                      );
                      if (updatedStudent != null) {
                        onEdit(updatedStudent);
                        Navigator.pop(context); // Повернутися до списку
                      }
                    },
                    child: const Text('Редагувати'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onDelete();
                      Navigator.pop(context); // Повернутися до списку
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Видалити'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
