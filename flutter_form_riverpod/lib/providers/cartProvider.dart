import 'package:flutter_form/models/cart.dart';
import 'package:flutter_form/models/doctor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  // Створюємо порожню корзину
  return CartNotifier(Cart(doctorsChosen: []));
});

// Клас для управління станом корзини
class CartNotifier extends StateNotifier<Cart> {
  CartNotifier(Cart state) : super(state);

  // Метод для додавання у корзину
  void addItem(Doctor doctor) {
    state.addItem(doctor);
    // Повідомляємо слухачів про зміну стану
    state = Cart(doctorsChosen: state.doctorsChosen);
  }

  // Метод для видалення з корзини
  void removeItem(Doctor doctor) {
    state.removeItem(doctor);
    // Повідомляємо слухачів про зміну стану
    state = Cart(doctorsChosen: state.doctorsChosen);
  }
}
