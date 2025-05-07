import 'package:flutter/material.dart';
import 'package:flutter_routes/students/student.dart';

// 2. сторінка додавання обєкту
class AddStudentPage extends StatefulWidget {
  // створити обєкт бажаного класу
  final Student? student;
  const AddStudentPage({Key? key, this.student}) : super(key: key);

  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  // для форми ключ
  final _formKey = GlobalKey<FormState>();
  // контролер для ПІБ та курсу, який потім можна валідувати.
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  // поля потрібні для вибору значення
  String? _faculty;
  bool _scolarhip = false;

  @override
  void initState() {
    // Коментар із оф.документації. Called when this object is inserted into the tree.
    super.initState();
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _courseController.text = widget.student!.course.toString();
      _faculty = widget.student!.faculty;
      _scolarhip = widget.student!.scolarhip;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student == null ? 'Додати студента' : 'Редагувати студента',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // форма вводу тексту
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ПІБ'),
                // валідуємо значення
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ПІБ не може бути порожнім';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Курс'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Курс не може бути порожнім';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0 || price >= 6) {
                    return 'Курс має бути більше за 0 і менше за 6';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Факультет'),
                value: _faculty,
                items: const [
                  DropdownMenuItem(value: 'ФМЦТ', child: Text('ФМЦТ')),
                  DropdownMenuItem(value: 'ФІТ', child: Text('ФІТ')),
                  DropdownMenuItem(value: 'ІТФ', child: Text('ІТФ')),
                ],
                onChanged: (value) => setState(() => _faculty = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Виберіть факультет';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('Стипендія'),
                value: _scolarhip,
                onChanged: (value) => setState(() => _scolarhip = value!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      // створюємо обєкт бажаного класу
                      Student(
                        name: _nameController.text,
                        course: int.parse(_courseController.text),
                        faculty: _faculty!,
                        scolarhip: _scolarhip,
                      ),
                    );
                  }
                },
                child: const Text('Зберегти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
