import 'package:flutter/material.dart';
import 'package:flutter_form/Car.dart';
import 'package:flutter_form/pages/AddCarPage.dart';
import 'package:flutter_form/pages/ViewCarPage.dart';

class ListCarPage extends StatefulWidget {
  const ListCarPage({super.key});

  @override
  State<ListCarPage> createState() => _ListCarPageState();
}

class _ListCarPageState extends State<ListCarPage> {
  final List<Car> _cars = [];

  void addCar(Car car) {
    setState(() {
      _cars.add(car);
    });
  }

  void updateCar(int index, Car updatedCar) {
    setState(() {
      _cars[index] = updatedCar;
    });
  }

  void deleteCar(int index) {
    setState(() {
      _cars.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сторінка перегляду списку")),
      body:
          _cars.isEmpty
              ? const Center(child: Text('Список порожній'))
              : ListView.builder(
                itemCount: _cars.length,
                itemBuilder: (context, index) {
                  final car = _cars[index];
                  return ListTile(
                    title: Text(car.model),
                    subtitle: Text('Ціна: ${car.price.toString()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteCar(index),
                    ),
                    onTap: () {
                      // навігатор перехід
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ViewCarPage(
                                car: car,
                                onDelete: () => deleteCar(index),
                                onEdit:
                                    (updatedCar) =>
                                        updateCar(index, updatedCar),
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
          final newCar = await Navigator.push<Car>(
            context,
            MaterialPageRoute(builder: (context) => const AddCarPage()),
          );
          if (newCar != null) {
            addCar(newCar);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
