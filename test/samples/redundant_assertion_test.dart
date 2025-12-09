import 'package:test/test.dart';


class Cosa {
  final String name;
  Cosa(this.name);
}

class User {
  final int id;
  final String name;

  User({required this.id, required this.name}) {
    if (id <= 0) throw ArgumentError('ID must be positive');
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
  }
}

class MapState {
  final Map<String, dynamic> data;
  MapState(this.data);
  
  static MapState empty() => MapState({});
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is MapState && data.toString() == other.data.toString();
  
  @override
  int get hashCode => data.hashCode;
}

enum Color { WHITE, BLACK, RED, BLUE }

extension ColorExtension on Color {
  bool isWhite() => this == Color.WHITE;
  bool isBlack() => this == Color.BLACK;
}

class Calculator {
  int add(int a, int b) => a + b;
  int multiply(int a, int b) => a * b;
}

class FooViewModel {
  String get mainFoo => "foo";
  int calculate() => 42;
}

void main() {
  group('Case 1: Tautological Comparisons', () {
    
    // DEVE DETECTAR: Compara a mesma coisa
    test('SMELL: Tautology - MapState.empty()', () {
      expect(MapState.empty(), MapState.empty());
    });

    // DEVE DETECTAR: Compara a mesma expressão
    test('SMELL: Tautology - Same method call', () {
      final calc = Calculator();
      expect(calc.add(2, 3), calc.add(2, 3));
    });

    // NÃO DEVE DETECTAR: Compara resultado com valor esperado
    test('VALID: Compare result with expected value', () {
      final state = MapState.empty();
      expect(state.data, isEmpty);
    });

    // NÃO DEVE DETECTAR: Compara método com valor específico
    test('VALID: Compare method result with specific value', () {
      final calc = Calculator();
      expect(calc.add(2, 3), equals(5));
    });
  });

  group('Case 2: Obvious Literals', () {
    
    // DEVE DETECTAR: Literais idênticos
    test('SMELL: Obvious literal - expect(2, 2)', () {
      expect(2, 2);
    });

    // DEVE DETECTAR: Booleans idênticos
    test('SMELL: Obvious literal - expect(true, true)', () {
      expect(true, true);
    });

    // DEVE DETECTAR: Sempre falso
    test('SMELL: Obvious literal - expect(true, false)', () {
      expect(true, false);
    });

    // DEVE DETECTAR: Strings idênticas
    test('SMELL: Obvious literal - expect("a", "a")', () {
      expect("test", "test");
    });

    // DEVE DETECTAR: Com matcher equals
    test('SMELL: Obvious literal - expect(2, equals(2))', () {
      expect(2, equals(2));
    });

    //  NÃO DEVE DETECTAR: Compara resultado com literal
    test('VALID: Compare calculation with literal', () {
      final calc = Calculator();
      expect(calc.add(1, 1), equals(2));
    });

    //  NÃO DEVE DETECTAR: Compara variável com literal
    test('VALID: Compare variable with literal', () {
      final value = 2 + 2;
      expect(value, equals(4));
    });
  });

  group('Case 3: Always True Assertions', () {
    
    // DEVE DETECTAR: expect(true, qualquerCoisa)
    test('SMELL: Always true - expect(true, isTrue)', () {
      expect(true, isTrue);
    });

    // DEVE DETECTAR: Verificação óbvia de identidade
    test('SMELL: Always true - WHITE.isWhite()', () {
      expect(Color.WHITE.isWhite(), true);
    });

    // DEVE DETECTAR: Verificação óbvia invertida
    test('SMELL: Always true - true == WHITE.isWhite()', () {
      expect(true, Color.WHITE.isWhite());
    });

    // NÃO DEVE DETECTAR: Testa lógica real com caso positivo E negativo
    test('VALID: Logic test with positive case', () {
      expect(Color.WHITE.isWhite(), isTrue);
    });

    test('VALID: Logic test with negative case', () {
      expect(Color.BLACK.isWhite(), isFalse);
    });

    // NÃO DEVE DETECTAR: Testa condição real
    test('VALID: Test real condition', () {
      final value = 10;
      expect(value > 5, isTrue);
    });

    // NÃO DEVE DETECTAR: Testa resultado de cálculo
    test('VALID: Test calculation result', () {
      final calc = Calculator();
      final result = calc.multiply(3, 4);
      expect(result == 12, isTrue);
    });
  });


  group('Case 4: Immediate Assignment Check', () {
    
    // DEVE DETECTAR: Atribui e verifica != null imediatamente
    test('SMELL: Immediate assignment - result != null', () {
      final sut = FooViewModel();
      var result = sut.mainFoo;
      expect(result != null, true);
    });


    // DEVE DETECTAR: Atribui propriedade e verifica
    test('SMELL: Immediate assignment - property check', () {
      final user = User(id: 1, name: "John");
      var userName = user.name;
      expect(userName, isNotNull);
    });

    // NÃO DEVE DETECTAR: Atribui E testa o VALOR real
    test('VALID: Assignment with value check', () {
      final sut = FooViewModel();
      var result = sut.mainFoo;
      expect(result, equals("foo"));
    });

    // NÃO DEVE DETECTAR: Atribui com transformação
    test('VALID: Assignment with transformation', () {
      final sut = FooViewModel();
      var result = sut.mainFoo.toUpperCase();
      expect(result, isNotNull);
    });

    // NÃO DEVE DETECTAR: Múltiplas operações entre atribuição e assert
    test('VALID: Multiple operations before check', () {
      final calc = Calculator();
      var result = calc.add(2, 3);
      result = calc.multiply(result, 2);
      expect(result, isNotNull);
    });

    // NÃO DEVE DETECTAR: Método pode retornar null
    test('VALID: Method that can return null', () {
      final list = <String>[];
      var result = list.firstWhere((e) => e == "test", orElse: () => null as String);
      expect(result, isNull);
    });
  });


// ============================================================================
// CASO 5: CONSTRUTOR SIMPLES + isNotNull
// ============================================================================

  group('Case 5: Constructor Null Check', () {
    
    // DEVE DETECTAR: Construtor simples + isNotNull
    test('SMELL: Constructor null check - simple', () {
      var item = Cosa("Towel");
      expect(item, isNotNull);
    });

    // DEVE DETECTAR: new + isNotNull
    test('SMELL: Constructor null check - with new', () {
      var item = new Cosa("Towel");
      expect(item, isNotNull);
    });

    // DEVE DETECTAR: Construtor + != null
    test('SMELL: Constructor null check - != null', () {
      var cosa = Cosa("Test");
      expect(cosa != null, true);
    });


    // NÃO DEVE DETECTAR: Construtor COM validação
    test('VALID: Constructor with validation', () {
      expect(() => User(id: -1, name: "Test"), throwsArgumentError);
    });

    // NÃO DEVE DETECTAR: Testa propriedade, não existência
    test('VALID: Test property value', () {
      var item = Cosa("Towel");
      expect(item.name, equals("Towel"));
    });

    // NÃO DEVE DETECTAR: Construtor + transformação
    test('VALID: Constructor with transformation', () {
      var item = Cosa("test");
      expect(item.name.toUpperCase(), equals("TEST"));
    });

    // NÃO DEVE DETECTAR: Factory que pode retornar null
    test('VALID: Factory method that can return null', () {
      int? parseValue(String s) {
        try {
          return int.parse(s);
        } catch (e) {
          return null;
        }
      }
      
      var result = parseValue("abc");
      expect(result, isNull);
    });
  });
  group('Case 6: Edge Cases and Mixed Scenarios', () {
    
    // DEVE DETECTAR: Múltiplos problemas - tautologia + literal
    test('SMELL: Multiple issues', () {
      expect(2, 2);
    });

    // DEVE DETECTAR: TODO com assertion dummy
    test('SMELL: TODO with dummy assertion', () {
      // TODO: implement real test
      expect(2, 2);
    });

    // NÃO DEVE DETECTAR: Teste de exceção
    test('VALID: Exception test', () {
      expect(() => User(id: 0, name: ""), throwsArgumentError);
    });

    // NÃO DEVE DETECTAR: Teste com setup complexo
    test('VALID: Complex setup', () {
      final calc = Calculator();
      final step1 = calc.add(2, 3);
      final step2 = calc.multiply(step1, 2);
      expect(step2, equals(10));
    });

    // NÃO DEVE DETECTAR: Teste de estado após operação
    test('VALID: State test after operation', () {
      final map = <String, int>{};
      map['key'] = 42;
      expect(map['key'], equals(42));
    });

    // NÃO DEVE DETECTAR: Verificação de tipo após cast
    test('VALID: Type check after operation', () {
      dynamic value = "42";
      var parsed = int.tryParse(value);
      expect(parsed is int?, true);
    });
  });

  group('Case 7: Not Redundant (Other smells)', () {
    
    // Estes NÃO são Redundant Assertion, mas podem ser outros smells:
    
    // Duplicate Assert (não Redundant!)
    test('NOT REDUNDANT: This is Duplicate Assert smell', () {
      final calc = Calculator();
      calc.add(2, 3);
      expect(calc.add(2, 3), equals(5));
      expect(calc.add(2, 3), equals(5)); // Duplicate, não redundant
    });

    // Assertion Roulette (múltiplos asserts sem mensagem)
    test('NOT REDUNDANT: This is Assertion Roulette', () {
      final user = User(id: 1, name: "John");
      expect(user.id, equals(1));
      expect(user.name, equals("John"));
      // Múltiplos asserts válidos, não redundant
    });

    // Eager Test (testa múltiplas coisas)
    test('NOT REDUNDANT: This is Eager Test', () {
      final calc = Calculator();
      expect(calc.add(2, 3), equals(5));
      expect(calc.multiply(2, 3), equals(6));
      // Testa múltiplas operações, não redundant
    });
  });
}
