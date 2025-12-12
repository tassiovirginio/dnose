import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ExpectedResolutionOmissionDetector implements AbstractDetector {
  @override
  get testSmellName => "Expected Resolution Omission";

  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);
    testSmells.clear();
    _detect(e, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode node, TestClass testClass, String testName) {
    if (node is MethodInvocation) {
      if (node.methodName.name == 'expect') {
        _checkExpect(node, testClass, testName);
      } else if (node.methodName.name == 'expectLater') {
        _checkExpectLater(node, testClass, testName);
      }
    }

    node.childEntities
        .whereType<AstNode>()
        .forEach((child) => _detect(child, testClass, testName));
  }

  void _checkExpect(
      MethodInvocation node, TestClass testClass, String testName) {
    var args = node.argumentList.arguments;
    if (args.length < 2) return;

    var actual = args[0];
    var matcher = args[1];

    // REGRA 1: expect() com Future SEM await E SEM matcher assíncrono
    // Exemplo ERRADO: expect(Future.value(42), equals(42))
    // Exemplo CORRETO: expect(Future.value(42), completion(equals(42)))
    if (_isFuture(actual) && !_hasAwait(actual) && !_isAsyncMatcher(matcher)) {
      _addSmell(node, testClass, testName, 'Future without await or async matcher in expect()');
      return;
    }
  }

  void _checkExpectLater(
      MethodInvocation node, TestClass testClass, String testName) {
    var args = node.argumentList.arguments;
    if (args.length < 2) return;

    var actual = args[0];

    // REGRA 3: expectLater() com await
    // Exemplo: expectLater(await future, completes)
    if (_hasAwait(actual)) {
      _addSmell(node, testClass, testName, 'Unnecessary await in expectLater()');
      return;
    }
  }

  bool _isFuture(Expression expr) {
    // Verifica pelo tipo estático PRIMEIRO (mais confiável)
    var type = expr.staticType;
    if (type != null) {
      if (type is InterfaceType) {
        return type.isDartAsyncFuture || type.isDartAsyncFutureOr;
      }
      // Se tem tipo e NÃO é Future, retorna false
      return false;
    }

    // Se staticType é null, usa heurísticas CONSERVADORAS
    
    // Caso 1: Future.value(), Future.delayed(), Future.error()
    if (expr is MethodInvocation) {
      var target = expr.target;
      if (target is SimpleIdentifier && target.name == 'Future') {
        return true; // Future.value(), Future.delayed(), etc.
      }
      // Para outros métodos, assume que NÃO é Future (conservador)
      return false;
    }

    // Caso 2: Variável standalone - APENAS se termina com "future" ou é exatamente "future"
    if (expr is SimpleIdentifier) {
      var name = expr.name.toLowerCase();
      // Aceita: "future", "myFuture", "resultFuture"
      // Rejeita: "futureFired", "futureGroup" (future no meio/começo)
      return name == 'future' || name.endsWith('future');
    }

    // Property access → assume que NÃO é Future
    if (expr is PropertyAccess || expr is PrefixedIdentifier) {
      return false;
    }

    // Se não conseguimos determinar, assume que NÃO é Future (conservador)
    return false;
  }

  bool _hasAwait(Expression expr) {
    return expr is AwaitExpression;
  }

  bool _isAsyncMatcher(Expression matcher) {
    // Identificadores simples: completes, throwsException, etc.
    if (matcher is SimpleIdentifier) {
      return _isAsyncMatcherName(matcher.name);
    }

    // Chamadas de método: completion(...), throwsA(...)
    if (matcher is MethodInvocation) {
      return _isAsyncMatcherName(matcher.methodName.name);
    }

    return false;
  }

  bool _isAsyncMatcherName(String name) {
    const asyncMatchers = [
      'completion',
      'completes',
      'throwsA',
      'throwsException',
      'throwsArgumentError',
      'throwsStateError',
      'throwsFormatException',
      'throwsRangeError',
      'throwsNoSuchMethodError',
      'throwsUnimplementedError',
      'throwsUnsupportedError',
      'throwsConcurrentModificationError',
      'throwsCyclicInitializationError',
    ];
    return asyncMatchers.contains(name);
  }

  bool _isFutureInsideAwait(Expression expr) {
    if (expr is AwaitExpression) {
      var inner = expr.expression;
      return _isFuture(inner);
    }
    return false;
  }

  void _addSmell(
    MethodInvocation node,
    TestClass testClass,
    String testName,
    String reason,
  ) {
    testSmells.add(TestSmell(
      name: testSmellName,
      testName: testName,
      testClass: testClass,
      code: node.toSource(),
      codeMD5: Util.md5(node.toSource()),
      start: testClass.lineNumber(node.offset),
      end: testClass.lineNumber(node.end),
      collumnStart: testClass.columnNumber(node.offset),
      collumnEnd: testClass.columnNumber(node.end),
      codeTest: codeTest,
      codeTestMD5: Util.md5(codeTest!),
      startTest: startTest,
      endTest: endTest,
      offset: node.offset,
      endOffset: node.end,
    ));
  }

  @override
  String getDescription() {
    return '''
Detects 2 simple async issues in tests:
1. Future without await or async matcher in expect() - Testing Future with synchronous matcher
2. Unnecessary await in expectLater() - expectLater handles Futures automatically

Valid async matchers: completion(), completes, throwsA(), throwsException, etc.
''';
  }

  @override
  String getExample() {
    return '''
// WRONG:
expect(Future.value(42), equals(42));           // Missing await or async matcher
expectLater(await Future.value(42), completes); // Unnecessary await

// CORRECT:
expect(await Future.value(42), equals(42));     // With await
expect(Future.value(42), completion(equals(42)));  // With async matcher
expect(Future.value(42), completes);            // With async matcher
expectLater(Future.value(42), completes);       // No await needed
''';
  }
}