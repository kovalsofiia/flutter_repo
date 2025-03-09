import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController elevationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController imagePathController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isPopular = false;

  final dbOperations = DbOperations.fromSettings();

  void addPeak() async {
    Peak peak = Peak(
      name: nameController.text,
      elevation: int.parse(elevationController.text),
      location: locationController.text,
      description: descriptionController.text,
      imagePath: imagePathController.text, // Дозволяємо null
      isPopular: isPopular,
    );
    await dbOperations.addElement(peak.toMap());
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Peak'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: elevationController,
              decoration: const InputDecoration(labelText: 'Elevation (m)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: imagePathController,
              decoration: const InputDecoration(
                labelText: 'Image Path (optional)',
              ), // Зроблено optional
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Is Popular'),
                Switch(
                  value: isPopular,
                  onChanged: (value) {
                    setState(() {
                      isPopular = value;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: const Text('Add Peak'),
              onPressed: () {
                addPeak();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// REALTIME DB
// import 'package:flutter/material.dart';
// import 'package:myflutter/models/peak.dart';
// import 'package:myflutter/api/db_operations.dart';

// // Клас віджету для сторінки додавання вершини
// class AddPage extends StatefulWidget {
//   // Конструктор з іменованими параметрами
//   const AddPage({Key? key}) : super(key: key);

//   // Метод для створення стану віджету
//   @override
//   _AddPageState createState() => _AddPageState();
// }

// // Клас стану для сторінки додавання вершини
// class _AddPageState extends State<AddPage> {
//   // Контролери для полів введення
//   TextEditingController nameController = TextEditingController();
//   TextEditingController elevationController = TextEditingController();
//   TextEditingController locationController = TextEditingController();
//   TextEditingController imagePathController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   bool isPopular = false;

//   final dbOperations = DbOperations.fromSettings();

//   // Метод для додавання вершини до Firebase
//   void addPeak() async {
//     // Створити об'єкт Peak з даними з полів введення
//     Peak peak = Peak(
//       name: nameController.text,
//       elevation: int.parse(elevationController.text),
//       location: locationController.text,
//       description: descriptionController.text,
//       imagePath: imagePathController.text,
//       isPopular: isPopular,
//     );
//     // Викликати метод для додавання елемента до колекції "peaks"
//     await dbOperations.addElement(peak.toMap());
//     // Повернутися до попередньої сторінки з результатом true
//     Navigator.pop(context, true);
//   }

//   // Метод для побудови віджету
//   @override
//   Widget build(BuildContext context) {
//     // Повернути віджет Scaffold
//     return Scaffold(
//       // Задати заголовок
//       appBar: AppBar(
//         title: const Text('Add Peak'),
//         leading: IconButton(
//           // Задати властивість icon для вибору іконки
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             // Повернутися до попередньої сторінки
//             Navigator.pop(context, false);
//           },
//         ),
//       ),
//       // Задати тіло віджету Scaffold
//       body: Padding(
//         // Задати відступи
//         padding: const EdgeInsets.all(16.0),
//         // Задати віджет Column для вертикального розташування елементів
//         child: Column(
//           // Задати головну вісь для рівномірного розподілу простору
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           // Задати дочірні віджети
//           children: [
//             // Задати віджет TextField для введення назви вершини
//             TextField(
//               // Задати контролер
//               controller: nameController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             // Задати віджет TextField для введення висоти вершини
//             TextField(
//               // Задати контролер
//               controller: elevationController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Elevation (m)'),
//               // Задати тип клавіатури
//               keyboardType: TextInputType.number,
//             ),
//             // Задати віджет TextField для введення локації вершини
//             TextField(
//               // Задати контролер
//               controller: locationController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Location'),
//             ),
//             // Задати віджет TextField для введення шляху до зображення вершини
//             TextField(
//               // Задати контролер
//               controller: imagePathController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Image Path'),
//             ),
//             TextField(
//               // Задати контролер
//               controller: descriptionController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Is Popular'),
//                 Switch(
//                   value: isPopular,
//                   onChanged: (value) {
//                     setState(() {
//                       isPopular = value;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             // Задати віджет ElevatedButton для додавання вершини
//             ElevatedButton(
//               // Задати текст
//               child: const Text('Add Peak'),
//               // Задати метод onPressed для виконання дії при натисканні на кнопку
//               onPressed: () {
//                 // Викликати метод addPeak
//                 addPeak();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
