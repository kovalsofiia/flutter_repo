import 'package:flutter/material.dart';
import 'package:flutter_form/providers/cartProvider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Отримуємо синхронний стан провайдера корзини
    final cartState = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Корзина')),
      body:
          cartState.doctorsChosen.isEmpty
              ?
              // Якщо корзина порожня, то показуємо повідомлення про це
              const Center(child: Text('Корзина порожня'))
              // Якщо у корзині є товари, то показуємо їх у вигляд
              : ListView.builder(
                itemCount: cartState.doctorsChosen.length,
                itemBuilder: (context, index) {
                  // Отримуємо товар за індексом
                  final doctor = cartState.doctorsChosen[index];
                  return Card(
                    child: ListTile(
                      // Показуємо назву та ціну товару
                      title: Text(doctor.name),
                      subtitle: Text('${doctor.price} грн'),
                      // Додаємо кнопку для видалення товару з корзини
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Викликаємо метод провайдера корзини для видалення товару
                          ref.read(cartProvider.notifier).removeItem(doctor);
                          // Показуємо повідомлення про успішне видалення
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Послугу лікаря ${doctor.specialization} - ${doctor.name} видалено',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      // Додаємо панель з загальною сумою корзини та кнопкою для оформлення замовлення
      bottomNavigationBar: Container(
        height: 80,
        padding: EdgeInsets.all(16),
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Показуємо загальну суму корзини
            Text(
              'Загальна сума: ${cartState.getTotal()} грн',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            // Додаємо кнопку для оформлення замовлення
            ElevatedButton(
              child: Text('Перейти до оплати'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Оплата на суму: ${cartState.getTotal()} грн',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
