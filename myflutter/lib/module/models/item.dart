// Клас моделі для вершини
class Item {
  final String? key; // Ключ вершини в Cloud Firestore
  String name;
  String? imagePath; // Може бути null

  // Конструктор з іменованими параметрами
  Item({
    this.key,
    required this.name,
    this.imagePath = 'assets/def-item.png', // Дефолтне значення
  });

  // Метод для перетворення мапи в об'єкт Item
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      key: map['key'],
      name: map['name'],
      imagePath: map['imagePath'],
    );
  }

  // Метод для перетворення об'єкта Item в мапу
  Map<String, dynamic> toMap() {
    return {'name': name, 'imagePath': imagePath};
  }
}
