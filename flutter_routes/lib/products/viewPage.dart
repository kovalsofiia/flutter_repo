import 'package:flutter/material.dart';
import 'package:flutter_routes/models/product.dart';
import 'package:flutter_routes/products/addPage.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final ValueChanged<Product> onEdit;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Деталі товару')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Назва: ${product.name}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Ціна: ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Категорія: ${product.category}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Безкоштовна доставка: ${product.freeDelivery ? "Так" : "Ні"}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Оплата частинами: ${product.installments}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // передаємо у роутер обєкт продукту
                    onPressed: () async {
                      final updatedProduct = await Navigator.push<Product>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddProductPage(product: product),
                        ),
                      );
                      if (updatedProduct != null) {
                        onEdit(updatedProduct);
                        Navigator.pop(context); // Повернутися до списку товарів
                      }
                    },
                    child: const Text('Редагувати'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onDelete();
                      Navigator.pop(context); // Повернутися до списку товарів
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Видалити'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
