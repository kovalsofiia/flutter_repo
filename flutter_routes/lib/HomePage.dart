import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Home Page (using named routes)')),
      body: ListView(
        children: [
          ListTile(
            title: Text("Persons List (assets and router topic)"),
            onTap: () {
              Navigator.pushNamed(context, '/list');
            },
          ),
          ListTile(
            title: Text("Input Page"),
            onTap: () {
              Navigator.pushNamed(context, '/input');
            },
          ),
          ListTile(
            title: Text("Students Page (task for assets)"),
            onTap: () {
              Navigator.pushNamed(context, '/students');
            },
          ),
          ListTile(
            title: Text("Product Form Page (input topic)"),
            onTap: () {
              Navigator.pushNamed(context, '/productForm');
            },
          ),
          ListTile(
            title: Text("Products Page (input with list saving topic)"),
            onTap: () {
              Navigator.pushNamed(context, '/products');
            },
          ),
          ListTile(
            title: Text("Input task page"),
            onTap: () {
              Navigator.pushNamed(context, '/22');
            },
          ),
          ListTile(
            title: Text("Students input form task page"),
            onTap: () {
              Navigator.pushNamed(context, '/stud');
            },
          ),
        ],
      ),
    );
  }
}
