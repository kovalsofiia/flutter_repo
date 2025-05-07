import 'package:flutter/material.dart';
import 'package:flutter_form/Car.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key, this.car});
  final Car? car;

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  // для форми ключ
  final _formKey = GlobalKey<FormState>();
  // контролери для полей авто, які потім можна валідувати.
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  // поля потрібні для вибору значення
  String? _color;

  void initState() {
    // Коментар із оф.документації. Called when this object is inserted into the tree.
    super.initState();
    if (widget.car != null) {
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
      _priceController.text = widget.car!.price.toString();
      _color = widget.car!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Форма для обробки інформації про авто")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // форма вводу тексту
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Модель авто'),
                // валідуємо значення
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Модель не може бути порожнім';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Рік'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Рік не може бути порожнім';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year <= 0 || year >= 2027) {
                    return 'Рік має бути більше за 0 і менше або рівне 2026';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Ціна'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ціна не може бути порожнім';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Ціна має бути більше за 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Колір'),
                value: _color,
                items: const [
                  DropdownMenuItem(value: 'Чорний', child: Text('Чорний')),
                  DropdownMenuItem(value: 'Білий', child: Text('Білий')),
                  DropdownMenuItem(value: 'Червоний', child: Text('Червоний')),
                ],
                onChanged: (value) => setState(() => _color = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Виберіть колір';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      // створюємо обєкт бажаного класу
                      Car(
                        model: _modelController.text,
                        year: int.parse(_yearController.text),
                        price: int.parse(_priceController.text),
                        color: _color!,
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
