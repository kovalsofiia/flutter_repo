// Клас моделі для об'єкта
class Item {
  final String? key; // Ключ об'єкта в Cloud Firestore
  String name;
  String birthYear;
  String mobileNumber;
  String cellularNumber;
  String? imagePath; // Може бути null

  // Конструктор з іменованими параметрами
  Item({
    this.key,
    required this.name,
    required this.birthYear,
    required this.mobileNumber,
    required this.cellularNumber,
    this.imagePath = 'assets/def-item.png', // Дефолтне значення
  });

  // Метод для перетворення мапи в об'єкт Item
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'] ?? '',
      birthYear: map['birthYear'] ?? 0,
      mobileNumber: map['mobileNumber'] ?? '',
      cellularNumber: map['cellularNumber'] ?? '',
      imagePath: map['imagePath'],
      key: map['key'],
    );
  }

  // Метод для перетворення об'єкта Item в мапу
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthYear': birthYear,
      'mobileNumber': mobileNumber,
      'cellularNumber': cellularNumber,
      'imagePath': imagePath,
    };
  }
}
