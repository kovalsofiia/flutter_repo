import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  ProductFormState createState() => ProductFormState();
}

class ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  bool _freeDelivery = false;
  String? _installments;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product form page')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Назва продукту'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Назва не може бути порожньою';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Ціна'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ціна не може бути порожньою';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0 || price >= 100000) {
                    return 'Ціна має бути більше за 0 і менше за 100000';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Категорія'),
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'Їжа', child: Text('Їжа')),
                  DropdownMenuItem(
                    value: 'Електроніка',
                    child: Text('Електроніка'),
                  ),
                  DropdownMenuItem(
                    value: 'Транспорт',
                    child: Text('Транспорт'),
                  ),
                  DropdownMenuItem(value: 'Інше', child: Text('Інше')),
                ],
                onChanged: (value) => setState(() => _category = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Виберіть категорію';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text("Оплата частинами"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Можлива'),
                      value: 'Можлива',
                      groupValue: _installments,
                      onChanged:
                          (value) => setState(() => _installments = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Не можлива'),
                      value: 'Не можлива',
                      groupValue: _installments,
                      onChanged:
                          (value) => setState(() => _installments = value),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: const Text('Безкоштовна доставка'),
                value: _freeDelivery,
                onChanged: (value) => setState(() => _freeDelivery = value!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(content: Text('Дані обробляються')),
                        )
                        .closed
                        .then((_) {
                          // Показати діалогове вікно після зникнення Snackbar
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Інформація про продукт'),
                                content: Text(
                                  'Назва: ${_nameController.text}\n'
                                  'Ціна: ${_priceController.text}\n'
                                  'Категорія: $_category\n'
                                  'Оплата частинами: $_installments\n'
                                  'Безкоштовна доставка: ${_freeDelivery ? 'Так' : 'Ні'}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('Закрити'),
                                  ),
                                ],
                              );
                            },
                          );
                        });
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
