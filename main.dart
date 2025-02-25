import 'dart:io';

// Константа з назвою калькулятора
const String calculatorName = "DartCalc 1.0";

// Фінальна змінна з поточною датою і часом запуску
final DateTime startTime = DateTime.now();

// Функція для додавання
double add(double a, double b) {
  return a + b;
}

// Функція для віднімання
double subtract(double a, double b) {
  return a - b;
}

// Функція для множення
double multiply(double a, double b) {
  return a * b;
}

// Функція для ділення
double divide(double a, double b) {
  // перевірка ділення на нуль
  if (b == 0) {
    print("Помилка: ділення на нуль!");
    return 0;
  }
  return a / b;
}

// Функція, яка приймає символ операції у рядковому типі даних і повертає відповідну функцію типу Function
Function? getOperation(String operation) {
  switch (operation) {
    case '+':
      return add;
    case '-':
      return subtract;
    case '*':
      return multiply;
    case '/':
      return divide;
    default:
      print("Невідома операція: $operation");
      return null; // Повертаємо null для невідомих операцій
  }
}

// функція для друку основної інформації про додаток і поточну дату виконання
void printInfo() {
  print("Ласкаво просимо до $calculatorName!");
  print("Час запуску: $startTime");
}

// функція виконання програми
void runProgram() {
  printInfo();
  bool continueCalc = true;
  // цикл while виконується поки користувач не вирішить вийти.
  while (continueCalc) {
    stdout.write("Введіть перше число: ");
    double num1 = double.parse(stdin.readLineSync()!);

    stdout.write("Введіть операцію (+, -, *, /): ");
    String operation = stdin.readLineSync()!;

    stdout.write("Введіть друге число: ");
    double num2 = double.parse(stdin.readLineSync()!);

    // Отримуємо функцію операції
    Function? selectedOperation = getOperation(operation);

    // перевірка чи обрана операція для виконання і чи коректна
    if (selectedOperation != null) {
      // Виконуємо обчислення
      double result = selectedOperation(num1, num2);
      print("Результат: $num1 $operation $num2 = $result");
    } else {
      print("Операція не підтримується.");
    }

    stdout.write("Продовжити роботу? (yes/no): ");
    String userInput = stdin.readLineSync()!.trim().toLowerCase();

    // Перевірка на завершення роботи
    if (userInput != "yes") {
      continueCalc = false;
      print("Thank you for using $calculatorName!. Goodbye!");
    }
  }
}

// Програма повинна містити головну функцію main, яка слугує точкою входу.
void main() {
  runProgram();
}
