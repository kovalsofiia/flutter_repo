import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
// import 'package:myflutter/pages/add_page.dart';
// import 'package:myflutter/pages/edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Peak> peaks = [];
  List<Peak> popularPeaks = [];
  final dbOperations = DbOperations.fromSettings();
  late bool isLoading;

  String? _sortValue;

  bool showPopular = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    loadPeaks();
  }

  Future<void> loadPopularPeaks() async {
    List<Map<String, dynamic>> data = await dbOperations.loadByPopularTag();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    setState(() {
      popularPeaks = loadedPeaks;
      isLoading = false;
    });
  }

  Future<List<Peak>> loadPeaks() async {
    List<Map<String, dynamic>> data =
        await dbOperations.readCollectionWithKeys();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    loadedPeaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    setState(() {
      isLoading = false;
      peaks = loadedPeaks;
      showPopular = false; // Set showPopular to false
    });
    return loadedPeaks;
  }

  void removePeak(Peak peak) async {
    await dbOperations.removeElement(peak.key!);
    setState(() {
      peaks.remove(peak);
    });
  }

  // void navigateToAddPage() async {
  //   bool result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const AddPage()),
  //   );
  //   if (result == true) {
  //     loadPeaks();
  //   }
  // }

  // void navigateToEditPage(Peak peak) async {
  //   bool result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => EditPage(peak: peak)),
  //   );
  //   if (result == true) {
  //     loadPeaks();
  //   }
  // }

  void navigateToAddPage() async {
    var result = await Navigator.pushNamed(context, '/add');
    if (result is bool && result == true) {
      loadPeaks();
    }
  }

  void navigateToEditPage(Peak peak) async {
    var result = await Navigator.pushNamed(context, '/edit', arguments: peak);
    if (result is bool && result == true) {
      loadPeaks();
    }
  }

  void navigateToViewPage(Peak peak) async {
    var result = await Navigator.pushNamed(context, '/view', arguments: peak);
    if (result is bool && result == true) {
      loadPeaks();
    }
  }

  void loadPopular() async {
    await loadPopularPeaks();
    setState(() {
      showPopular = true; // Set showPopular to true
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            loadPeaks();
          },
          child: Text('Peaks'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              loadPopular();
            },
            child: Text('View Popular Peaks'),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              navigateToAddPage();
            },
          ),
          DropdownButton<String>(
            value: _sortValue,
            hint: Text('Sort'),
            items: [
              DropdownMenuItem(child: Text('A-Z'), value: 'a-z'),
              DropdownMenuItem(child: Text('Z-A'), value: 'z-a'),
              DropdownMenuItem(
                child: Text('From highest to lowest'),
                value: '1-0',
              ),
              DropdownMenuItem(
                child: Text('From lowest to highest'),
                value: '0-1',
              ),
            ],
            onChanged: (value) {
              setState(() {
                _sortValue = value;
                switch (_sortValue) {
                  case 'a-z':
                    peaks.sort((a, b) => a.name.compareTo(b.name));
                    break;
                  case 'z-a':
                    peaks.sort((a, b) => b.name.compareTo(a.name));
                    break;
                  case '0-1':
                    peaks.sort((a, b) => a.elevation.compareTo(b.elevation));
                    break;
                  case '1-0':
                    peaks.sort((a, b) => b.elevation.compareTo(a.elevation));
                    break;
                  default: // Handle default sorting here
                    peaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : ListView.builder(
                  itemCount: showPopular ? popularPeaks.length : peaks.length,
                  itemBuilder: (context, index) {
                    Peak peak =
                        showPopular ? popularPeaks[index] : peaks[index];
                    return Dismissible(
                      key: Key(peak.key!),
                      onDismissed: (direction) {
                        removePeak(peak);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Peak removed')),
                        );
                      },
                      child: ListTile(
                        leading:
                            peak.imagePath != null && peak.imagePath!.isNotEmpty
                                ? Image.network(peak.imagePath!)
                                : Image.asset('assets/default.png'),
                        title: Text(peak.name),
                        subtitle: Text('${peak.elevation} m, ${peak.location}'),
                        onTap: () {
                          navigateToViewPage(peak);
                        },
                        trailing: Row(
                          // Wrap trailing widgets in a Row
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (peak
                                .isPopular) // Conditionally show the yellow box
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("Popular"),
                              ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                navigateToEditPage(peak);
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

// REALTIME DB
// import 'package:flutter/material.dart';
// import 'package:myflutter/models/peak.dart';
// import 'package:myflutter/api/db_operations.dart';
// import 'package:myflutter/pages/add_page.dart';
// import 'package:myflutter/pages/edit_page.dart';
// import 'dart:io';

// // Клас віджету для головної сторінки
// class HomePage extends StatefulWidget {
//   // Конструктор з іменованими параметрами
//   const HomePage({Key? key}) : super(key: key);

//   // Метод для створення стану віджету
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// // Клас стану для головної сторінки
// class _HomePageState extends State<HomePage> {
//   // Список вершин
//   List<Peak> peaks = [];
//   final dbOperations = DbOperations.fromSettings();

//   late bool isLoading;
//   @override
//   void initState() {
//     setState(() {
//       isLoading = true;
//     });
//     loadPeaks();
//   }

//   // Метод для завантаження вершин з Firebase
//   Future<List<Peak>> loadPeaks() async {
//     // Викликати метод для зчитування колекції "peaks"
//     List<Map<String, dynamic>> data = await dbOperations.readCollection();
//     // Перетворити список мап в список об'єктів Peak
//     List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
//     // Оновити стан віджету з новим списком вершин
//     setState(() {
//       isLoading = false;
//       peaks = loadedPeaks;
//     });
//     return loadedPeaks;
//   }

//   // Метод для вилучення вершини з Firebase
//   void removePeak(Peak peak) async {
//     // Викликати статичний метод Flutter для вилучення елемента з колекції "peaks" за ключем
//     await dbOperations.removeElement(peak.key!);
//     // Оновити стан віджету з новим списком вершин
//     setState(() {
//       peaks.remove(peak);
//     });
//   }

//   // Метод для навігації до сторінки додавання вершини
//   void navigateToAddPage() async {
//     // Викликати метод Navigator.push для переходу до сторінки AddPage
//     bool result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AddPage()),
//     );

//     // Якщо результат true, то оновити список вершин
//     if (result == true) {
//       loadPeaks();
//     }
//   }

//   // Метод для навігації до сторінки редагування вершини
//   void navigateToEditPage(Peak peak) async {
//     // Викликати метод Navigator.push для переходу до сторінки EditPage з параметром peak
//     bool result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => EditPage(peak: peak)),
//     );
//     // Якщо результат true, то оновити список вершин
//     if (result == true) {
//       loadPeaks();
//     }
//   }

//   // Метод для побудови віджету
//   @override
//   Widget build(BuildContext context) {
//     // Повернути віджет Scaffold
//     return Scaffold(
//       // Задати заголовок
//       appBar: AppBar(
//         title: Text('Peaks'),
//         actions: [
//           // Задати віджет IconButton для створення кнопки з іконкою
//           IconButton(
//             // Задати властивість icon для вибору іконки
//             icon: Icon(Icons.add),
//             // Задати властивість onPressed для виконання дії
//             onPressed: () {
//               navigateToAddPage();
//             },
//           ),
//         ],
//       ),
//       // Задати тіло віджету Scaffold
//       body: Center(
//         // Задати віджет FutureBuilder для асинхронного завантаження вершин
//         child:
//             isLoading
//                 ? CircularProgressIndicator()
//                 : ListView.builder(
//                   // Задати кількість елементів списку
//                   itemCount: peaks.length,
//                   // Задати метод itemBuilder для побудови кожного елемента списку
//                   itemBuilder: (context, index) {
//                     // Отримати поточну вершину зі списку
//                     Peak peak = peaks[index];
//                     // Повернути віджет Dismissible для можливості вилучення вершини
//                     return Dismissible(
//                       // Задати ключ для віджету Dismissible
//                       key: Key(peak.key!),
//                       // Задати метод onDismissed для виконання дії при вилученні вершини
//                       onDismissed: (direction) {
//                         // Викликати метод removePeak для вилучення вершини з Firebase
//                         removePeak(peak);
//                         // Показати повідомлення про вилучення вершини
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Peak removed')),
//                         );
//                       },
//                       // Задати віджет ListTile для відображення інформації про вершину
//                       child: ListTile(
//                         // Задати зображення вершини за шляхом
//                         leading:
//                             peak.imagePath != null
//                                 ? Image.network(peak.imagePath!)
//                                 : Icon(Icons.landscape),
//                         // Задати назву вершини
//                         title: Text(peak.name),
//                         // Задати висоту та розташування вершини
//                         subtitle: Text('${peak.elevation} m, ${peak.location}'),
//                         // Задати метод onTap для навігації до сторінки редагування вершини
//                         onTap: () {
//                           // Викликати метод navigateToEditPage з параметром peak
//                           navigateToEditPage(peak);
//                         },
//                       ),
//                     );
//                   },
//                 ),
//       ),
//     );
//   }
// }
