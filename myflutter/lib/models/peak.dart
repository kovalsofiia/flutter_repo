import 'package:cloud_firestore/cloud_firestore.dart';

// Клас моделі для вершини
class Peak {
  final String? key; // Ключ вершини в Cloud Firestore
  String name;
  int elevation;
  String location;
  String description;
  String? imagePath; // Може бути null
  bool isPopular;
  final Timestamp? timestamp; // Add a Timestamp field

  // Конструктор з іменованими параметрами
  Peak({
    this.key,
    required this.name,
    required this.elevation,
    required this.location,
    required this.description,
    this.imagePath = 'assets/default_peak.png', // Дефолтне значення
    this.isPopular = false, // Дефолтне значення
    this.timestamp, // Add timestamp to the constructor
  });

  // Метод для перетворення мапи в об'єкт Peak
  factory Peak.fromMap(Map<String, dynamic> map) {
    return Peak(
      key: map['key'],
      name: map['name'],
      elevation:
          map['elevation'] != null
              ? map['elevation'].toInt()
              : 0, // Перевірка на null
      location: map['location'],
      description: map['description'],
      imagePath: map['imagePath'],
      isPopular: map['isPopular'] ?? false, // Перевірка на null
      timestamp:
          map['timestamp'] != null
              ? map['timestamp'] as Timestamp
              : null, // Handle null case and cast to Timestamp
    );
  }

  // Метод для перетворення об'єкта Peak в мапу
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'elevation': elevation,
      'location': location,
      'description': description,
      'imagePath': imagePath,
      'isPopular': isPopular,
      'timestamp':
          timestamp ?? FieldValue.serverTimestamp(), // Add timestamp to the map
    };
  }
}

// REALTIME DB
// // Клас моделі для товару
// class Peak {
//   final String? key; // Ключ товару в Firebase
//   String name;
//   int elevation;
//   String location;
//   String description;
//   String imagePath;
//   bool isPopular;

//   // Конструктор з іменованими параметрами
//   Peak({
//     this.key,
//     required this.name,
//     required this.elevation,
//     required this.location,
//     required this.description,
//     required this.imagePath,
//     this.isPopular = false,
//   });

//   // Метод для перетворення мапи в об'єкт Product
//   factory Peak.fromMap(Map<String, dynamic> map) {
//     return Peak(
//       key: map['key'],
//       name: map['name'],
//       elevation: map['elevation'].toInt(),
//       location: map['location'],
//       description: map['description'],
//       imagePath: map['imagePath'],
//       isPopular: map['isPopular'],
//     );
//   }

//   // Метод для перетворення об'єкта Product в мапу
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'elevation': elevation,
//       'location': location,
//       'description': description,
//       'imagePath': imagePath,
//       'isPopular': isPopular,
//     };
//   }
// }
