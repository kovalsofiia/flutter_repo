import 'package:flutter/material.dart';
import 'package:myflutter/module/api/db_op_items.dart';
import 'package:myflutter/module/models/item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> items = [];
  final dbOperations = DbOperations.fromSettings();
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadItems();
  }

  Future<List<Item>> loadItems() async {
    List<Map<String, dynamic>> data =
        await dbOperations.readCollectionWithKeys();
    List<Item> loadedItems = data.map((map) => Item.fromMap(map)).toList();
    setState(() {
      isLoading = false;
      items = loadedItems;
    });
    return loadedItems;
  }

  void removeItem(Item item) async {
    await dbOperations.removeElement(item.key!);
    setState(() {
      items.remove(item);
    });
  }

  void navigateToAddPage() async {
    var result = await Navigator.pushNamed(context, '/add');
    if (result is bool && result == true) {
      loadItems();
    }
  }

  void navigateToEditPage(Item item) async {
    var result = await Navigator.pushNamed(context, '/edit', arguments: item);
    if (result is bool && result == true) {
      loadItems();
    }
  }

  void navigateToViewPage(Item item) async {
    var result = await Navigator.pushNamed(context, '/view', arguments: item);
    if (result is bool && result == true) {
      loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: GestureDetector(
          onTap: () => loadItems(),
          child: const Text(
            'Items',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: navigateToAddPage),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Item item = items[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.blue[50],
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              item.imagePath != null &&
                                      item.imagePath!.isNotEmpty
                                  ? Image.network(
                                    item.imagePath!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/def-item.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue[900],
                          ),
                        ),
                        onTap: () => navigateToViewPage(item),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue[800],
                              onPressed: () => navigateToEditPage(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                          'Are you sure you want to delete this item?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              removeItem(item);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Item removed'),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
