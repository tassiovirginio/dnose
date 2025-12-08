import 'package:test/test.dart';

void main() {
  test('ERO1: Missing await on Future', () {
    final future = Future.value(42);
    expect(future, equals(42)); // Should have await
  });

  test('ERO2: Exception without throwsA', () async {
    final future = Future.error(Exception('fail'));
    expect(await future, isA<Exception>()); // Should use throwsA
  });

  test('ERO3: Using await with completes matcher', () async {
    final future = Future.value(42);
    expect(await future, completes); // Incorrect, should be expectLater
  });

  test('ERO4: Ignoring async behavior', () {
    final future = Future.delayed(Duration(seconds: 1), () => 42);
    expect(future, equals(42)); // Missing await, may pass incorrectly
  });

  // Correct examples
  test('Correct: Proper await', () async {
    final future = Future.value(42);
    expect(await future, equals(42));
  });

  test('Correct: Exception with throwsA', () {
    final future = Future.error(Exception('fail'));
    expect(future, throwsA(isA<Exception>()));
  });

  test('Correct: Using expectLater with completes', () {
    final future = Future.value(42);
    expectLater(future, completes);
  });
}
