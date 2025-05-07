import 'package:flutter/material.dart';
import 'package:flutter_routes/models/product.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({Key? key, this.product}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _category;
  bool _freeDelivery = false;
  String? _installments;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _category = widget.product!.category;
      _freeDelivery = widget.product!.freeDelivery;
      _installments = widget.product!.installments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Додати товар' : 'Редагувати товар',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                    Navigator.pop(
                      context,
                      Product(
                        name: _nameController.text,
                        price: double.parse(_priceController.text),
                        category: _category!,
                        freeDelivery: _freeDelivery,
                        installments: _installments!,
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
