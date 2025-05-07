import 'package:flutter/material.dart';
import 'package:flutter_routes/models/product.dart';
import 'package:flutter_routes/products/addPage.dart';
import 'package:flutter_routes/products/viewPage.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // список обєктів
  final List<Product> _products = [];

  // функція додавання обєкту
  void _addProduct(Product product) {
    setState(() {
      _products.add(product);
    });
  }

  // функція оновлення обєкту
  void _updateProduct(int index, Product updatedProduct) {
    setState(() {
      _products[index] = updatedProduct;
    });
  }

  // функція видалення обєкту
  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список товарів')),
      body:
          // перевіряємо чи не пустий список
          _products.isEmpty
              ? const Center(child: Text('Список порожній'))
              : ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('Ціна: ${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(index),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductDetailPage(
                                product: product,
                                onDelete: () => _deleteProduct(index),
                                onEdit:
                                    (updatedProduct) =>
                                        _updateProduct(index, updatedProduct),
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
          final newProduct = await Navigator.push<Product>(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
          if (newProduct != null) {
            _addProduct(newProduct);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
