import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class RedundantAssertionDetector implements AbstractDetector {
  @override
  get testSmellName => "Redundant Assertion";

  List<TestSmell> testSmells = [];

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    testSmells = [];

    // Find the test function body block
    final testBlock = _findTestBlock(e);
    if (testBlock != null) {
      // Traverse the test body to find all expect statements
      _scanForExpects(testBlock, testClass, testName, testBlock);
    }

    return testSmells;
  }

  Block? _findTestBlock(ExpressionStatement testFunction) {
    // The test function should have a function body that contains the test code
    if (testFunction.expression is MethodInvocation) {
      final invocation = testFunction.expression as MethodInvocation;
      if (invocation.argumentList.arguments.length >= 2) {
        final secondArg = invocation.argumentList.arguments[1];
        if (secondArg is FunctionExpression) {
          final body = secondArg.body;
          if (body is BlockFunctionBody) {
            return body.block;
          }
        }
      }
    }
    return null;
  }

  void _scanForExpects(AstNode node, TestClass testClass, String testName, Block testBlock) {
    if (node is ExpressionStatement && _isExpect(node)) {
      final invocation = node.expression as MethodInvocation;
      final args = invocation.argumentList.arguments;

      if (args.length < 2) return;

      final actual = args[0];
      final matcher = args[1];

      // Detecção 1: Comparações tautológicas (expect(x, x))
      if (_isTautology(actual, matcher)) {
        testSmells.add(_createTestSmell(node, testClass, testName, "Tautological comparison"));
        return;
      }

      // Detecção 2: Literais óbvios (expect(true, true), expect(2, 2))
      if (_isObviousLiteral(actual, matcher)) {
        testSmells.add(_createTestSmell(node, testClass, testName, "Obvious literal comparison"));
        return;
      }

      // Detecção 2.5: Literais sempre falsos (expect(true, false), expect(2, 3))
      if (_isAlwaysFalse(actual, matcher)) {
        testSmells.add(_createTestSmell(node, testClass, testName, "Always false assertion"));
        return;
      }

      // Detecção 3: Verificações sempre verdadeiras
      if (_isAlwaysTrue(actual, matcher)) {
        testSmells.add(_createTestSmell(node, testClass, testName, "Always true assertion"));
        return;
      }

      // Detecção 4: Variável atribuída imediatamente antes e testada sem transformação
      if (_isImmediateAssignmentCheck(node, testClass, testBlock)) {
        testSmells.add(_createTestSmell(node, testClass, testName, "Immediate assignment check"));
        return;
      }

      // Detecção 5: Construtor simples seguido de isNotNull
      if (_isConstructorNullCheck(node, testClass, testBlock)) {
        testSmells.add(_createTestSmell(node, testClass, testName, "Constructor null check"));
        return;
      }
    }

    // Recursively scan child nodes
    for (var child in node.childEntities) {
      if (child is AstNode) {
        _scanForExpects(child, testClass, testName, testBlock);
      }
    }
  }

  // Verifica se é um expect(...)
  bool _isExpect(Statement stmt) {
    if (stmt is ExpressionStatement && stmt.expression is MethodInvocation) {
      final invocation = stmt.expression as MethodInvocation;
      return invocation.methodName.name == "expect";
    }
    return false;
  }

  // Detecção 1: Comparações tautológicas
  // Exemplo: expect(MapState.empty(), MapState.empty())
  bool _isTautology(Expression actual, Expression matcher) {
    // Remove matchers como equals(), isTrue, etc
    final cleanMatcher = _unwrapMatcher(matcher);

    // Compara se são identicamente iguais
    final actualSource = actual.toSource().trim();
    final matcherSource = cleanMatcher.toSource().trim();

    return actualSource == matcherSource;
  }

  // Detecção 2: Literais óbvios
  // Exemplo: expect(true, true), expect(2, 2), expect(false, false)
  bool _isObviousLiteral(Expression actual, Expression matcher) {
    final cleanMatcher = _unwrapMatcher(matcher);

    // Verifica se ambos são literais booleanos
    if (actual is BooleanLiteral && cleanMatcher is BooleanLiteral) {
      return actual.value == cleanMatcher.value;
    }

    // Verifica expect(true, isTrue) ou expect(false, isFalse)
    if (actual is BooleanLiteral) {
      if (actual.value == true && _isMatcherTrue(matcher)) {
        return true;
      }
      if (actual.value == false && _isMatcherFalse(matcher)) {
        return true;
      }
    }

    if (actual is IntegerLiteral && cleanMatcher is IntegerLiteral) {
      return actual.value == cleanMatcher.value;
    }

    if (actual is DoubleLiteral && cleanMatcher is DoubleLiteral) {
      return actual.value == cleanMatcher.value;
    }

    if (actual is StringLiteral && cleanMatcher is StringLiteral) {
      return actual.stringValue == cleanMatcher.stringValue;
    }

    return false;
  }

  // Detecção 2.5: Literais sempre falsos
  // Exemplo: expect(true, false), expect(2, 3), expect("a", "b")
  bool _isAlwaysFalse(Expression actual, Expression matcher) {
    final cleanMatcher = _unwrapMatcher(matcher);

    // Verifica se ambos são literais booleanos diferentes
    if (actual is BooleanLiteral && cleanMatcher is BooleanLiteral) {
      return actual.value != cleanMatcher.value;
    }

    // Verifica expect(true, isFalse) ou expect(false, isTrue)
    if (actual is BooleanLiteral) {
      if (actual.value == true && _isMatcherFalse(matcher)) {
        return true;
      }
      if (actual.value == false && _isMatcherTrue(matcher)) {
        return true;
      }
    }

    // Verifica expect(false, isTrue)
    if (actual is BooleanLiteral && actual.value == false && _isMatcherTrue(matcher)) {
      return true;
    }

    // Literais numéricos diferentes
    if (actual is IntegerLiteral && cleanMatcher is IntegerLiteral) {
      return actual.value != cleanMatcher.value;
    }

    if (actual is DoubleLiteral && cleanMatcher is DoubleLiteral) {
      return actual.value != cleanMatcher.value;
    }

    // Strings diferentes
    if (actual is StringLiteral && cleanMatcher is StringLiteral) {
      return actual.stringValue != cleanMatcher.stringValue;
    }

    return false;
  }

  // Detecção 3: Assertions sempre verdadeiras
  // Exemplo: expect(true, isTrue), expect(WHITE.isWhite(), true)
  bool _isAlwaysTrue(Expression actual, Expression matcher) {
    // expect(true, qualquerCoisa) ou expect(qualquerCoisa, true)
    if (actual is BooleanLiteral && actual.value == true) {
      return true;
    }
    
    final cleanMatcher = _unwrapMatcher(matcher);
    if (cleanMatcher is BooleanLiteral && cleanMatcher.value == true) {
      // Verifica se o actual é uma verificação óbvia
      final actualSource = actual.toSource();
      
      // Padrões óbvios: WHITE.isWhite(), Black.isBlack(), etc
      if (actualSource.contains('.is') && 
          _isObviousIdentityCheck(actualSource)) {
        return true;
      }
    }
    
    // expect(x != null, true) após atribuição direta
    if (actual is BinaryExpression && 
        actual.operator.toString() == '!=' &&
        actual.rightOperand.toSource() == 'null') {
      return _wasJustAssigned(actual.leftOperand);
    }
    
    return false;
  }

  // Verifica padrões como WHITE.isWhite(), Black.isDark()
  bool _isObviousIdentityCheck(String expression) {
    final patterns = [
      RegExp(r'WHITE\.isWhite\(\)'),
      RegExp(r'BLACK\.isBlack\(\)'),
      RegExp(r'RED\.isRed\(\)'),
      RegExp(r'BLUE\.isBlue\(\)'),
      RegExp(r'(\w+)\.is\1\(\)', caseSensitive: false),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(expression));
  }

  // Detecção 4: Variável atribuída e imediatamente verificada
  // Exemplo: var result = sut.mainFoo; expect(result != null, true);
  bool _isImmediateAssignmentCheck(ExpressionStatement e, TestClass testClass, Block testBlock) {
    final statements = testBlock.statements;
    final index = statements.indexOf(e);

    if (index <= 0) return false;

    // Pega o statement anterior
    final previousStmt = statements[index - 1];

    // Verifica se é uma atribuição de variável
    if (previousStmt is VariableDeclarationStatement) {
      final variables = previousStmt.variables.variables;

      for (var variable in variables) {
        final varName = variable.name.lexeme;
        final expectSource = e.toSource();

        // Se o expect usa essa variável e verifica != null ou isNotNull
        if (expectSource.contains(varName) &&
            (expectSource.contains('!= null') ||
             expectSource.contains('isNotNull'))) {

          // Verifica se não há nenhuma transformação
          final initializer = variable.initializer;
          if (initializer != null &&
              !_hasTransformation(initializer) &&
              !_isMethodCallWithSideEffects(initializer)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // Detecção 5: Construtor simples seguido de isNotNull
  // Exemplo: var item = new Cosa("Towel"); expect(item, isNotNull);
  bool _isConstructorNullCheck(ExpressionStatement e, TestClass testClass, Block testBlock) {
    final statements = testBlock.statements;
    final index = statements.indexOf(e);

    final expectSource = e.toSource();

    // Verifica se o expect contém isNotNull
    if (!expectSource.contains('isNotNull') && !expectSource.contains('!= null')) {
      return false;
    }

    // Primeiro, verifica se é um expect com chamada de construtor inline
    // Exemplo: expect(Cosa("Towel"), isNotNull);
    final invocation = e.expression as MethodInvocation;
    final args = invocation.argumentList.arguments;
    if (args.isNotEmpty && args[0] is InstanceCreationExpression) {
      final constructorCall = args[0] as InstanceCreationExpression;
      if (!_hasComplexConstructorLogic(constructorCall)) {
        return true;
      }
    }

    // Procura por declarações de variáveis anteriores próximas (até 5 statements antes)
    for (int i = index - 1; i >= 0 && i >= index - 5; i--) {
      final stmt = statements[i];

      if (stmt is VariableDeclarationStatement) {
        final variables = stmt.variables.variables;

        for (var variable in variables) {
          final varName = variable.name.lexeme;

          // Se o expect usa essa variável
          if (expectSource.contains(varName)) {
            final initializer = variable.initializer;

            // Verifica se é uma instanciação simples de construtor
            if (initializer is InstanceCreationExpression) {
              // Se não há lógica complexa no construtor, é redundante
              if (!_hasComplexConstructorLogic(initializer)) {
                return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  // Verifica se há transformação/lógica na expressão
  bool _hasTransformation(Expression expr) {
    // Se tem chamadas de método que transformam (map, where, toUpperCase, etc)
    if (expr is MethodInvocation) {
      final methodName = expr.methodName.name;
      final transformMethods = [
        'map', 'where', 'fold', 'reduce', 'toUpperCase', 'toLowerCase',
        'trim', 'split', 'join', 'substring', 'replaceAll', 'parse'
      ];
      return transformMethods.contains(methodName);
    }
    
    // Se tem operações aritméticas ou concatenação
    if (expr is BinaryExpression) {
      final operators = ['+', '-', '*', '/', '%', '??'];
      return operators.contains(expr.operator.toString());
    }
    
    return false;
  }

  // Verifica se é uma chamada de método com efeitos colaterais
  bool _isMethodCallWithSideEffects(Expression expr) {
    if (expr is MethodInvocation) {
      final methodName = expr.methodName.name;
      // Métodos que claramente têm lógica/efeitos
      final sideEffectMethods = [
        'fetch', 'get', 'post', 'put', 'delete', 'load', 'save',
        'calculate', 'compute', 'process', 'validate', 'parse'
      ];
      return sideEffectMethods.any((m) => methodName.contains(m));
    }
    return false;
  }

  // Verifica se o construtor tem lógica complexa (validações, cálculos)
  bool _hasComplexConstructorLogic(InstanceCreationExpression creation) {
    // Se tem múltiplos argumentos ou argumentos complexos, assume que pode ter lógica
    final args = creation.argumentList.arguments;
    
    // Construtores com muitos argumentos provavelmente têm validação
    if (args.length > 3) return true;
    
    // Se algum argumento é uma expressão complexa
    for (var arg in args) {
      if (arg is BinaryExpression || 
          arg is ConditionalExpression ||
          arg is MethodInvocation) {
        return true;
      }
    }
    
    return false;
  }

  // Verifica se uma variável foi recém-atribuída
  bool _wasJustAssigned(Expression expr) {
    // Simplificação: assume que se é um identificador simples, pode ter sido atribuído
    return expr is SimpleIdentifier;
  }

  // Remove wrappers de matchers (equals, isTrue, etc)
  Expression _unwrapMatcher(Expression matcher) {
    if (matcher is MethodInvocation) {
      final methodName = matcher.methodName.name;
      
      // equals(x) → x
      if (methodName == 'equals' && matcher.argumentList.arguments.isNotEmpty) {
        return matcher.argumentList.arguments.first;
      }
    }
    
    return matcher;
  }
  
  // Verifica se o matcher é isTrue ou isFalse
  bool _isMatcherTrue(Expression matcher) {
    if (matcher is MethodInvocation) {
      return matcher.methodName.name == 'isTrue';
    }
    return false;
  }
  
  bool _isMatcherFalse(Expression matcher) {
    if (matcher is MethodInvocation) {
      return matcher.methodName.name == 'isFalse';
    }
    return false;
  }

  // Cria um TestSmell
  TestSmell _createTestSmell(
      ExpressionStatement e, 
      TestClass testClass, 
      String testName,
      String reason) {
    return TestSmell(
      name: testSmellName,
      testName: testName,
      testClass: testClass,
      code: e.toSource(),
      codeMD5: Util.md5(e.toSource()),
      start: testClass.lineNumber(e.offset),
      end: testClass.lineNumber(e.end),
      collumnStart: testClass.columnNumber(e.offset),
      collumnEnd: testClass.columnNumber(e.end),
      codeTest: e.toSource(),
      codeTestMD5: Util.md5(e.toSource()),
      startTest: testClass.lineNumber(e.offset),
      endTest: testClass.lineNumber(e.end),
      offset: e.offset,
      endOffset: e.end,
    );
  }

  Block? _getParentBlock(AstNode node) {
    AstNode? n = node;
    while (n != null && n is! Block) {
      n = n.parent;
    }
    return n is Block ? n : null;
  }

  @override
  String getDescription() {
    return '''
Occurs when a test contains assertions whose results are always true or always false,
regardless of the implementation. This includes tautological comparisons, obvious literals,
constructor null checks without validation logic, and immediate assignment checks without
transformation. Redundant assertions create a false sense of test coverage without actually
validating any real behavior or business logic.
''';
  }

  @override
  String getExample() {
    return '''
// Redundant examples:
expect(2, 2); // always true
expect(true, equals(false)); // always false
expect(MapState.empty(), MapState.empty()); // tautology
var item = Cosa("x"); expect(item, isNotNull); // constructor check
var result = sut.mainFoo; expect(result != null, true); // immediate assignment
expect(true, Color.WHITE.isWhite()); // obvious identity

// Valid examples:
expect(cart.getTotalPrice(), equals(30)); // tests calculation
expect(() => User(id: -1), throwsError); // tests validation
expect(Color.RED.isWhite(), isFalse); // tests logic with negative case
''';
  }
}