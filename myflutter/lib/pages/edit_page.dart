import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';

class EditPage extends StatefulWidget {
  final Peak peak;

  const EditPage({Key? key, required this.peak}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController elevationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imagePathController = TextEditingController();
  bool isPopular = false;

  final dbOperations = DbOperations.fromSettings();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.peak.name;
    elevationController.text = widget.peak.elevation.toString();
    locationController.text = widget.peak.location;
    descriptionController.text = widget.peak.description;
    imagePathController.text = widget.peak.imagePath ?? ''; // Обробка null
    isPopular = widget.peak.isPopular;
  }

  void updatePeak() async {
    Peak peak = Peak(
      key: widget.peak.key,
      name: nameController.text,
      elevation: int.parse(elevationController.text),
      location: locationController.text,
      description: descriptionController.text,
      imagePath: imagePathController.text, // Дозволяємо null
      isPopular: isPopular,
      timestamp: widget.peak.timestamp, // Keep the old timestamp for updates
      // Update timestamp on update
    );
    await dbOperations.updateElement(peak.key!, peak.toMap());
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Peak'),
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
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: imagePathController,
              decoration: const InputDecoration(
                labelText: 'Image Path (optional)',
              ), // Зроблено optional
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
              child: const Text('Update Peak'),
              onPressed: () {
                updatePeak();
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

// // Клас віджету для сторінки редагування вершини
// class EditPage extends StatefulWidget {
//   // Параметр для передачі об'єкта Peak
//   final Peak peak;

//   // Конструктор з іменованими параметрами
//   const EditPage({Key? key, required this.peak}) : super(key: key);

//   // Метод для створення стану віджету
//   @override
//   _EditPageState createState() => _EditPageState();
// }

// // Клас стану для сторінки редагування вершини
// class _EditPageState extends State<EditPage> {
//   // Контролери для полів введення
//   TextEditingController nameController = TextEditingController();
//   TextEditingController elevationController = TextEditingController();
//   TextEditingController locationController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   TextEditingController imagePathController = TextEditingController();
//   bool isPopular = false;

//   final dbOperations = DbOperations.fromSettings();

//   // Метод для ініціалізації стану віджету
//   @override
//   void initState() {
//     // Викликати метод initState суперкласу
//     super.initState();
//     // Задати значення контролерів з параметра peak
//     nameController.text = widget.peak.name;
//     elevationController.text = widget.peak.elevation.toString();
//     locationController.text = widget.peak.location;
//     descriptionController.text = widget.peak.description;
//     imagePathController.text = widget.peak.imagePath;
//     isPopular = widget.peak.isPopular;
//   }

//   // Метод для оновлення вершини в Firebase
//   void updatePeak() async {
//     // Створити об'єкт Peak з даними з полів введення
//     Peak peak = Peak(
//       key: widget.peak.key,
//       name: nameController.text,
//       elevation: int.parse(elevationController.text),
//       location: locationController.text,
//       description: descriptionController.text,
//       imagePath: imagePathController.text,
//       isPopular: isPopular,
//     );
//     // Викликати статичний метод Flutter для оновлення елемента в колекції "peaks" за ключем
//     await dbOperations.updateElement(peak.key!, peak.toMap());
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
//         title: Text('Edit Peak'),
//         leading: IconButton(
//           // Задати властивість icon для вибору іконки
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             // повернутися до попередньої сторінки
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
//             TextField(
//               // Задати контролер
//               controller: descriptionController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//             TextField(
//               // Задати контролер
//               controller: imagePathController,
//               // Задати підказку
//               decoration: const InputDecoration(labelText: 'Image Path'),
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
//             // Задати віджет ElevatedButton для оновлення вершини
//             ElevatedButton(
//               // Задати текст
//               child: const Text('Update Peak'),
//               // Задати метод onPressed для виконання дії при натисканні на кнопку
//               onPressed: () {
//                 // Викликати метод updatePeak
//                 updatePeak();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
