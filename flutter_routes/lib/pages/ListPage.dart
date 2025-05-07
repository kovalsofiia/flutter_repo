import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// сторінка перегляду усіх обєктів із джсон файлу. використано стейтлес віджет, бо не передбачено змін.
class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Persons List')),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/data/list.json'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error loading data');
          } else {
            // розписуємо вміст файлу джсон
            final dataList = json.decode(snapshot.data!)['items'];
            // повертаємо збудований список
            return ListView.builder(
              // кількість та білдер це базова інформація потрібна для відображення списку
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                // повертаємо карточку списка
                return ListTile(
                  // тайтл - імя
                  title: Text(dataList[index]['name']),
                  // при натисканні передаємо інформацію
                  onTap: () {
                    // final не можна змінити після призначення
                    final personData =
                        dataList[index]; // Отримуємо дані з списку
                    Navigator.pushNamed(
                      context,
                      '/person',
                      arguments:
                          personData, // Передаємо об'єкт personData як аргумент
                    );
                  },
                  // () => Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => Person(person: dataList[index]),
                  //   ),
                  // ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
