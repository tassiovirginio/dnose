import 'package:test/test.dart';

// ============================================================================
// VARIÁVEIS GLOBAIS SEM RESET - DEVEM CAUSAR SMELLS
// ============================================================================

int counter = 0;
String message = '';
List<int> sharedList = [];
Map<String, int> cache = {};
bool flag = false;
double value = 0.0;

// ============================================================================
// VARIÁVEIS GLOBAIS COM RESET EM setUp - NÃO DEVEM CAUSAR SMELLS
// ============================================================================

late int safeCounter;
late String safeMessage;

void main() {
  
  // setUp reseta apenas algumas variáveis
  setUp(() {
    safeCounter = 0;
    safeMessage = '';
  });

  // ==========================================================================
  // DEPENDENT TEST SMELLS - 9 CASOS
  // ==========================================================================

  // SMELL 1 e 2: counter usado em 2 testes sem reset
  test('DT1: increments counter', () {
    counter++;
    expect(counter, greaterThan(0));
  });

  test('DT2: expects zero counter', () {
    expect(counter, 0);
  });

  // SMELL 3 e 4: message usado em 2 testes sem reset
  test('DT3: sets message', () {
    message = 'Hello';
    expect(message, equals('Hello'));
  });

  test('DT4: expects empty message', () {
    expect(message, isEmpty);
  });

  // SMELL 5, 6 e 7: sharedList usado em 3 testes sem reset
  test('DT5: adds to list', () {
    sharedList.add(1);
    expect(sharedList.length, equals(1));
  });

  test('DT6: adds more to list', () {
    sharedList.add(2);
    expect(sharedList.length, greaterThan(0));
  });

  test('DT7: expects empty list', () {
    expect(sharedList, isEmpty);
  });

  // SMELL 8 e 9: cache usado em 2 testes sem reset
  test('DT8: fills cache', () {
    cache['key'] = 42;
    expect(cache['key'], equals(42));
  });

  test('DT9: reads cache', () {
    expect(cache['key'], equals(42));
  });

  // SMELL 10 e 11: flag usado em 3 testes
  test('DT10: sets flag true', () {
    flag = true;
    expect(flag, isTrue);
  });

  test('DT11: expects flag true', () {
    expect(flag, isTrue);
  });

  test('DT12: sets flag false', () {
    flag = false;
    expect(flag, isFalse);
  });

  // SMELL 13 e 14: value usado em 3 testes
  test('DT13: sets value', () {
    value = 10.5;
    expect(value, equals(10.5));
  });

  test('DT14: doubles value', () {
    value = value * 2;
    expect(value, greaterThan(0));
  });

  test('DT15: expects zero value', () {
    expect(value, equals(0.0));
  });

  // ==========================================================================
  // TESTES VÁLIDOS - NÃO DEVEM SER DETECTADOS
  // ==========================================================================

  test('Valid1: increments safe counter', () {
    safeCounter++;
    expect(safeCounter, equals(1));
  });

  test('Valid2: safe counter reset', () {
    expect(safeCounter, equals(0));
  });

  test('Valid3: local variables only', () {
    int localCounter = 0;
    localCounter++;
    expect(localCounter, equals(1));
  });

  test('Valid4: safe message', () {
    safeMessage = 'Test';
    expect(safeMessage, equals('Test'));
  });

  test('Valid5: no global state', () {
    final data = [1, 2, 3];
    expect(data.length, equals(3));
  });
}