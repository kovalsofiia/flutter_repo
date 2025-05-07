import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

// даний віджет не оновлюється після створення. тобто його найкраще використати для певної інформації,яка не залежить від кнопок,форми введення і тд. тобто якісь константи.

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Stateless Widget Text Title',
      home: const HomePage(),
    );
  }
}

// цей віджет оновлюється після створення. наприклад може містити якусь інформацію після натискання кнопочки, або введення тексту у форму.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // _HomePageState createState() => _HomePageState();
  _ForHomePage createState() => _ForHomePage();
}

// розширює стейтфул віджет (той який змінюється)
class _HomePageState extends State<HomePage> {
  List _items = [];
  String _title = "Hello! This text is title, located inside Statefull widget.";
  String _btnTitle = "Press here to view list loaded from assets";
  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString(
      'assets/config/data.json',
    );
    final data = await json.decode(response);
    setState(() {
      _items = data["items"];
      _title = data["title"];
      _btnTitle = data["btnTitle"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(_title)),
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Image(image: AssetImage('assets/images/background.jpg')),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  ElevatedButton(child: Text(_btnTitle), onPressed: readJson),
                  // Display the data loaded from sample.json
                  _items.isNotEmpty
                      ? Expanded(
                        child: ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                leading: Text((index + 1).toString()),
                                title: Text(_items[index]["name"]),
                                subtitle: Text(_items[index]["description"]),
                              ),
                            );
                          },
                        ),
                      )
                      : Positioned(
                        top: 20,
                        child: Text(
                          'Thank you',
                          style: TextStyle(
                            fontSize: 40,
                            // fontFamily: 'Whisper',
                            color: Colors.blue[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForHomePage extends State<HomePage> {
  String _title = "Hello! This text is title, located inside Statefull widget.";

  TextEditingController nameController = TextEditingController();
  String fullName = '';

  void _updateText() {
    setState(() {
      fullName = nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(_title)),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                // рядок щоб форма введення і кнопка були як у рядку
                children: [
                  Expanded(
                    // текстове поле вводу буде мінятись за потреби
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Full Name',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _updateText,
                    child: const Text("My button"),
                  ),
                ],
              ),
            ),
            Text(fullName),
            Text("Example for Row and Column"),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'My text inside children array, that is inside Column, that is inside Center.',
                    ),
                    Text('Strawberry Pavlova'),
                    Text('Description for Pavlova'),
                    Text('Reviews'),
                  ],
                ),
                Image.asset('assets/images/pavlova.jpg', height: 300),
              ],
            ),
            const Text("Example for Expanded and ListView"),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Container(
                    height: 50,
                    color: Colors.amber[600],
                    child: const Center(child: Text('Entry A')),
                  ),
                  Container(
                    height: 50,
                    color: Colors.amber[500],
                    child: const Center(child: Text('Entry B')),
                  ),
                  Container(
                    height: 50,
                    color: Colors.amber[100],
                    child: const Center(child: Text('Entry C')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
