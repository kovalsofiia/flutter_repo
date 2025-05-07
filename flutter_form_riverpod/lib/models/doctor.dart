class Doctor {
  String name;
  String specialization;
  double price;

  Doctor({
    required this.name,
    required this.specialization,
    required this.price,
  });
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      specialization: json['specialization'],
      price:
          (json['price'] is String
                  ? double.parse(json['price'])
                  : json['price'].toDouble())
              as double,
    );
  }
}
