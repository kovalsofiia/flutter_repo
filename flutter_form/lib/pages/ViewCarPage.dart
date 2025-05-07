import 'package:flutter/material.dart';
import 'package:flutter_form/Car.dart';
import 'package:flutter_form/pages/AddCarPage.dart';

class ViewCarPage extends StatelessWidget {
  final Car car;
  final VoidCallback onDelete;
  final ValueChanged<Car> onEdit;
  const ViewCarPage({
    super.key,
    required this.car,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Перегляд одного авто")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Модель: ${car.model}', style: const TextStyle(fontSize: 18)),
          Text(
            'Рік: ${car.year.toString()}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Ціна: ${car.price.toString()}',
            style: const TextStyle(fontSize: 18),
          ),
          Text('Колір: ${car.color}', style: const TextStyle(fontSize: 18)),
          Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  // передаємо у роутер обєкт
                  onPressed: () async {
                    final updatedCar = await Navigator.push<Car>(
                      context,
                      MaterialPageRoute(builder: (context) => AddCarPage()),
                    );
                    if (updatedCar != null) {
                      onEdit(updatedCar);
                      Navigator.pop(context); // Повернутися до списку
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context); // Повернутися до списку
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
