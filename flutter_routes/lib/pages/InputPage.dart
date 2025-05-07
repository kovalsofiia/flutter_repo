import 'package:flutter/material.dart';

enum SingingCharacter { lafayette, jefferson }

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState(); // Змінено назву класу стану
}

class _InputPageState extends State<InputPage> {
  SingingCharacter? _character = SingingCharacter.lafayette;
  bool isChecked = false;
  String dropdownValue = 'One';

  TextEditingController nameController = TextEditingController();
  String fullName = '';

  final _numberFormKey = GlobalKey<FormState>(); // Ключ для форми числа
  final _numberController = TextEditingController();
  int? _enteredNumber;

  final _nameFormKey = GlobalKey<FormState>(); // Ключ для форми імені
  final _fullNameController =
      TextEditingController(); // Використовуємо більш стандартну назву
  String _enteredFullName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Page')),
      body: SingleChildScrollView(
        // Додано для прокрутки, якщо вміст не вміщається
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Інші елементи вводу"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Повне ім\'я (без валідації)',
              ),
              onChanged: (text) {
                setState(() {
                  fullName = text;
                });
              },
            ),
            Text(fullName),
            const SizedBox(height: 30),
            const Text("Введення числа з валідацією"),
            Form(
              key: _numberFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Введіть ціле число',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Будь ласка, введіть число';
                      }
                      final number = int.tryParse(value);
                      if (number == null) {
                        return 'Введіть дійсне ціле число';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_numberFormKey.currentState!.validate()) {
                        setState(() {
                          _enteredNumber = int.parse(_numberController.text);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Введено число: $_enteredNumber'),
                          ),
                        );
                      }
                    },
                    child: const Text('Підтвердити число'),
                  ),
                  if (_enteredNumber != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Ви ввели: $_enteredNumber',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Введення імені з валідацією"),
            Form(
              key: _nameFormKey, // Використовуємо окремий ключ для цієї форми
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller:
                        _fullNameController, // Використовуємо _fullNameController
                    decoration: const InputDecoration(
                      labelText: 'Введіть ім\'я',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Будь ласка, введіть ім\'я';
                      }
                      if (value.length < 2) {
                        return 'Ім\'я має містити щонайменше 2 символи';
                      }
                      if (!RegExp(
                        r'^[a-zA-Zа-яА-ЯіїІЇєЄґҐ\s]+$',
                      ).hasMatch(value)) {
                        return 'Ім\'я може містити лише літери та пробіли';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      setState(() {
                        _enteredFullName = text;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameFormKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Введено ім\'я: $_enteredFullName'),
                          ),
                        );
                        // Тут можна додати логіку для обробки введеного імені
                      }
                    },
                    child: const Text('Підтвердити ім\'я'),
                  ),
                  if (_enteredFullName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Ви ввели: $_enteredFullName',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Інші елементи вибору"),
            ListTile(
              title: const Text('Lafayette'),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.lafayette,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Thomas Jefferson'),
              leading: Radio<SingingCharacter>(
                value: SingingCharacter.jefferson,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    _character = value;
                  });
                },
              ),
            ),
            Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items:
                  <String>[
                    'One',
                    'Two',
                    'Three',
                    'Four',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
