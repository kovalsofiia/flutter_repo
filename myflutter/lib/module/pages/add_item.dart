import 'package:flutter/material.dart';
import 'package:myflutter/module/api/db_op_items.dart';
import 'package:myflutter/module/models/item.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController birthYearController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController cellularNumberController = TextEditingController();
  TextEditingController imagePathController = TextEditingController();

  final dbOperations = DbOperations.fromSettings();

  void addItem() async {
    if (_formKey.currentState!.validate()) {
      Item item = Item(
        name: nameController.text.trim(),
        birthYear: birthYearController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
        cellularNumber: cellularNumberController.text.trim(),
        imagePath:
            imagePathController.text.trim().isEmpty
                ? null
                : imagePathController.text.trim(),
      );
      await dbOperations.addElement(item.toMap());
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Add Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration('ПІБ'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'ПІБ є обовʼязковим';
                      }
                      final words = value.trim().split(RegExp(r'\s+'));
                      if (words.length < 3) {
                        return 'Введіть повне ПІБ';
                      }
                      if (!RegExp(
                        r"^[А-ЩЬЮЯЄІЇа-щьюяєії'\- ]+$",
                      ).hasMatch(value)) {
                        return 'ПІБ має містити лише українські літери';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: birthYearController,
                    decoration: _inputDecoration('Рік народження'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Рік народження is required';
                      }
                      final year = int.tryParse(value);
                      if (year == null ||
                          year < 1900 ||
                          year > DateTime.now().year) {
                        return 'Введіть коректний рік народження (1900 - 2025)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: mobileNumberController,
                    decoration: _inputDecoration(
                      'Номер стільникового телефону',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Номер стільникового телефону is required';
                      }
                      if (!RegExp(r'^\+?\d{10,13}$').hasMatch(value)) {
                        return 'Введіть коректний номер стільникового телефону(+380501112233)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cellularNumberController,
                    decoration: _inputDecoration('Номер мобільного телефону'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Номер мобільного телефону is required';
                      }
                      if (!RegExp(r'^\+?\d{10,13}$').hasMatch(value)) {
                        return 'Введіть коректний Номер мобільного телефону (+380501112233)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imagePathController,
                    decoration: _inputDecoration('Image Path (optional)'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    onPressed: addItem,
                    child: const Text(
                      'Add Item',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.blue[800]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue[700]!),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
