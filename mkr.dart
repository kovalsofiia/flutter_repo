import 'dart:io';
// MKR КОВАЛЬ СОФІЯ СА3
/*1. Дано :  . Знайти  .
2. Дано два натуральних числа. Знайти число, яке містить найбільшу кількість нулів, використовуючи функцію підрахунку нулів в натуральному числі.
3. Описати клас, який містять вказані поля і методи.
Клас “звичайний дріб” – TFraction
поля		для зберігання чисельника і знаменника;
методи		конструктор без параметрів, конструктор з параметрами, конструктор копіювання;
	введення/виведення даних;
	скорочення дробів (якщо чисельник і знаменник містять спільні множники);
	перевантаження операторів +, –, *, / .
*/

List<double> vector_z(List<double> x, List<double> y) {
  int n = x.length;
  List<double> z = [];
  for (int i = 0; i < n; i++) {
    z.add(x[i]);
    z.add(y[i]);
  }
  return z;
}

task1() {
  stdout.write("===============Завдання 1======================\n");
  stdout.write("Введіть вектор x через пробіл: ");
  List<double> x = stdin.readLineSync()!.split(' ').map(double.parse).toList();
  stdout.write("Введіть вектор y через пробіл: ");
  List<double> y = stdin.readLineSync()!.split(' ').map(double.parse).toList();
  if (x.length != y.length) {
    print("Помилка: Вектори повинні мати однакову довжину!");
    return;
  }
  List<double> z = vector_z(x, y);
  print("Результат: $z");
}

/*2.Дано два натуральних числа. Знайти число, яке містить найбільшу кількість нулів, використовуючи функцію підрахунку нулів в натуральному числі.*/
// Функція підрахунку кількості нулів у числі
int countZeros(int num) {
  return num.toString().split('').where((c) => c == '0').length;
}

// Функція для знаходження числа з найбільшою кількістю нулів
int findNumberWithMostZeros(List<int> numbers) {
  return numbers.reduce((a, b) => countZeros(a) >= countZeros(b) ? a : b);
}

void task2() {
  stdout.write("===============Завдання 2=====================\n");
  stdout.write("Введіть числа через пробіл (e.g., 1 2 3 4 5): ");
  String input = stdin.readLineSync()!;
  List<int> numbers = input.split(' ').map(int.parse).toList();
  print("Ваші числа: $numbers");
  int maxZeroNumber = findNumberWithMostZeros(numbers);
  print("Число з найбільшою кількістю нулів: $maxZeroNumber");
}

/*3. Описати клас, який містять вказані поля і методи.
Клас “звичайний дріб” – TFraction
поля		для зберігання чисельника і знаменника;
методи		конструктор без параметрів, конструктор з параметрами, конструктор копіювання;
	введення/виведення даних;
	скорочення дробів (якщо чисельник і знаменник містять спільні множники);
	перевантаження операторів +, –, *, / .*/

class TFraction {
  int chyselnyk;
  int znamennyk;
  //конструктор із параметрами, без параметрів
  TFraction([this.chyselnyk = 1, this.znamennyk = 1]) {
    _reduce();
  }
  //конструктор копіювання
  TFraction.copy(TFraction other)
    : chyselnyk = other.chyselnyk,
      znamennyk = other.znamennyk;

  void inputData() {
    stdout.write("Введіть чисельник: ");
    chyselnyk = int.parse(stdin.readLineSync()!);
    stdout.write("Введіть знаменник: ");
    znamennyk = int.parse(stdin.readLineSync()!);
    if (znamennyk == 0) {
      print("Знаменник не може бути нулем. Встановлено значення 1.");
      znamennyk = 1;
    }
    _reduce();
  }

  // Найбільший спільний дільник
  int _nsd(int a, int b) => b == 0 ? a.abs() : _nsd(b, a % b);

  void _reduce() {
    //скорочення дробу
    int nsd = _nsd(chyselnyk, znamennyk);
    chyselnyk ~/= nsd;
    znamennyk ~/= nsd;
  }

  @override
  String toString() => "$chyselnyk / $znamennyk";

  // Перевантаження операторів
  TFraction operator +(TFraction other) {
    int newNumerator =
        chyselnyk * other.znamennyk + other.chyselnyk * znamennyk;
    int newDenominator = znamennyk * other.znamennyk;
    return TFraction(newNumerator, newDenominator);
  }

  TFraction operator -(TFraction other) {
    int newNumerator =
        chyselnyk * other.znamennyk - other.chyselnyk * znamennyk;
    int newDenominator = znamennyk * other.znamennyk;
    return TFraction(newNumerator, newDenominator);
  }

  TFraction operator *(TFraction other) {
    return TFraction(chyselnyk * other.chyselnyk, znamennyk * other.znamennyk);
  }

  TFraction operator /(TFraction other) {
    return TFraction(chyselnyk * other.znamennyk, znamennyk * other.chyselnyk);
  }
}

void task3() {
  stdout.write("===============Завдання 3======================\n");

  TFraction drib1 = TFraction();
  print("Перший дріб:");
  drib1.inputData();

  TFraction drib2 = TFraction();
  print("Другий дріб:");
  drib2.inputData();

  print("Дріб 1: $drib1");
  print("Дріб 2: $drib2");
  print("Сума: ${drib1 + drib2}}");
  print("Різниця: ${drib1 - drib2}");
  print("Добуток: ${drib1 * drib2}");
  print("Частка: ${drib1 / drib2}");
}

void main() {
  task1();
  task2();
  task3();
}
