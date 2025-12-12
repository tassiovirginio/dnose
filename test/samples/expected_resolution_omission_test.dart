import 'package:test/test.dart';

void main() {
  // ==============================================
  // CASOS COM ERRO - DEVEM DETECTAR 6 SMELLS
  // ==============================================

  // --- ERRO 1: Future sem await no expect() (3 casos) ---
  test('ERO1: Future.value without await', () {
    final future = Future.value(42);
    expect(future, equals(42)); // SMELL #1
  });

  test('ERO2: Future.delayed without await', () {
    final future = Future.delayed(Duration(seconds: 1), () => 42);
    expect(future, equals(42)); // SMELL #2
  });

  test('ERO3: Future.error without await', () {
    final future = Future.error(Exception('error'));
    expect(future, equals(42)); // SMELL #3
  });

  // --- ERRO 2: await no expectLater() (3 casos) ---
  test('ERO4: expectLater with await', () async {
    final future = Future.value(42);
    expectLater(await future, completes); // SMELL #4
  });

  test('ERO5: expectLater with await #2', () async {
    expectLater(await Future.value(42), completes); // SMELL #5
  });

  test('ERO6: expectLater with await #3', () async {
    final future = Future.delayed(Duration(milliseconds: 10), () => 42);
    expectLater(await future, completes); // SMELL #6
  });

  // ==============================================
  // CASOS CORRETOS - NÃO DEVEM DETECTAR (0 SMELLS)
  // ==============================================

  test('CORRECT1: Proper await with expect', () async {
    final future = Future.value(42);
    expect(await future, equals(42)); // ✓ CORRETO
  });

  test('CORRECT2: No await on non-Future', () {
    expect(42, equals(42)); // ✓ CORRETO
  });

  test('CORRECT3: expectLater without await', () {
    final future = Future.value(42);
    expectLater(future, completes); // ✓ CORRETO
  });

  test('CORRECT4: expectLater with completion', () {
    expectLater(Future.value(42), completion(equals(42))); // ✓ CORRETO
  });

  test('CORRECT5: String without await', () {
    final str = 'hello';
    expect(str, equals('hello')); // ✓ CORRETO
  });

  test('CORRECT6: Multiple awaits', () async {
    expect(await Future.value(1), equals(1)); // ✓ CORRETO
    expect(await Future.value(2), equals(2)); // ✓ CORRETO
  });

  test('CORRECT7: Non-Future value', () {
    final value = 100;
    expect(value, equals(100)); // ✓ CORRETO
  });

  test('CORRECT8: await on actual Future', () async {
    expect(await Future.delayed(Duration(milliseconds: 1), () => 42), equals(42)); // ✓ CORRETO
  });

  test('CORRECT9: await on int literal does not compile', () async {
    // expect(await 42, equals(42)); // Isso nem compila!
    expect(42, equals(42)); // ✓ CORRETO
  });

  test('CORRECT10: await on String variable does not compile', () async {
    final value = 'hello';
    // expect(await value, equals('hello')); // Isso nem compila!
    expect(value, equals('hello')); // ✓ CORRETO
  });

  test('CORRECT11: Property access with "future" in name', () {
    // Simula futureGroup.isIdle - property não é Future
    final obj = _TestObject();
    expect(obj.futureResult, isFalse); // ✓ CORRETO - property bool, não Future
  });

  test('CORRECT12: Method call with "future" in object name', () {
    final futureGroup = _TestObject();
    expect(futureGroup.isIdle, isTrue); // ✓ CORRETO - property bool
  });

  test('CORRECT13: Variable with "future" in the middle of name', () {
    var futureFired = false;
    expect(futureFired, isFalse); // ✓ CORRETO - bool, não Future
  });

  test('CORRECT14: Variable starting with "future"', () {
    var futureResult = 42;
    expect(futureResult, equals(42)); // ✓ CORRETO - int, não Future
  });

  test('CORRECT15: Only variables ending with "future" trigger heuristic', () {
    var myFuture = Future.value(42); // Nome termina com "future"
    // Este DEVERIA detectar se não tiver await, mas é edge case
    // Na prática, staticType vai resolver
  });

  test('CORRECT16: Future with completion matcher', () {
    final future = Future.value(42);
    expect(future, completion(equals(42))); // ✓ CORRETO - matcher assíncrono
  });

  test('CORRECT17: Future with completes matcher', () {
    expect(Future.value(42), completes); // ✓ CORRETO - matcher assíncrono
  });

  test('CORRECT18: Future with throwsA matcher', () {
    expect(Future.error(Exception()), throwsA(isA<Exception>())); // ✓ CORRETO
  });

  test('CORRECT19: Future with throwsException', () {
    expect(Future.error(Exception()), throwsException); // ✓ CORRETO
  });

  test('CORRECT20: cancelFuture with completion', () {
    final cancelFuture = Future.value(42);
    expect(cancelFuture, completion(42)); // ✓ CORRETO - matcher assíncrono
  });
}

// Helper class para testes
class _TestObject {
  bool futureResult = false;
  bool isIdle = true;
}