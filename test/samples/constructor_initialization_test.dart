import 'package:test/test.dart';

class Calculator {
  int add(int a, int b) => a + b;
}

// SMELL: Test class with constructor initialization
class CalculatorTest {
  late Calculator calculator;

  // Constructor initializes test fixture
  CalculatorTest() {
    calculator = Calculator();
  }

  void run() {
    test('adds two numbers', () {
      expect(calculator.add(2, 3), 5);
    });

    test('subtracts two numbers', () {
      expect(calculator.add(5, -3), 2);
    });
  }
}

// Another smell: Constructor with field initialization
class AnotherTest {
  late String name;
  late int value;

  AnotherTest() {
    name = 'test';
    value = 42;
  }

  void run() {
    test('name is test', () {
      expect(name, equals('test'));
    });

    test('value is 42', () {
      expect(value, equals(42));
    });
  }
}

// Correct approach: No constructor, use setUp
void main() {
  late Calculator calculator;

  setUp(() {
    calculator = Calculator();
  });

  test('adds two numbers correctly', () {
    expect(calculator.add(2, 3), 5);
  });

  test('subtracts two numbers correctly', () {
    expect(calculator.add(5, -3), 2);
  });

  // Run the smelly tests
  CalculatorTest().run();
  AnotherTest().run();
}
