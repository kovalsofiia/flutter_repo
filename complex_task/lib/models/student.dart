class Student {
  final String name;
  final String course;
  final String averageScore;

  Student({
    required this.name,
    required this.course,
    required this.averageScore,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      course: json['course'],
      averageScore: json['averageScore'],
    );
  }
}
