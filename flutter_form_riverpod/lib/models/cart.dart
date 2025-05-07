import 'package:flutter_form/models/doctor.dart';

class Cart {
  // Список лікарів у корзині
  List<Doctor> doctorsChosen;

  Cart({required this.doctorsChosen});

  // Метод для додавання у корзину
  void addItem(Doctor doctor) {
    doctorsChosen.add(doctor);
  }

  // Метод для видалення з корзини
  void removeItem(Doctor doctor) {
    doctorsChosen.remove(doctor);
  }

  // Метод для обчислення загальної суми корзини
  double getTotal() {
    double total = 0;
    for (Doctor doctor in doctorsChosen) {
      total += doctor.price;
    }
    return total;
  }
}
