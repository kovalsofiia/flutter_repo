class Doctor {
  String name;
  String specialization;

  Doctor({required this.name, required this.specialization});
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(name: json['name'], specialization: json['specialization']);
  }
}
