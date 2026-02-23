import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class RedundantAssertionDetector extends AbstractDetector {
  @override
  get testSmellName => "Redundant Assertion";

  Block? _testBlock;

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    this.testSmells = [];
    this.testClass = testClass;
    this.testName = testName;
    this.codeTest = e.toSource();
    this.startTest = testClass.lineNumber(e.offset);
    this.endTest = testClass.lineNumber(e.end);

    // Find the test function body block
    _testBlock = _findTestBlock(e);
    if (_testBlock != null) {
      _testBlock!.accept(this);
    }

    return testSmells;
  }

  Block? _findTestBlock(ExpressionStatement testFunction) {
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

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    if (_isExpect(node)) {
      final invocation = node.expression as MethodInvocation;
      final args = invocation.argumentList.arguments;

      if (args.length >= 2) {
        final actual = args[0];
        final matcher = args[1];

        // Detecção 1: Comparações tautológicas (expect(x, x))
        if (_isTautology(actual, matcher)) {
          _addSmell(node, "Tautological comparison");
          return;
        }

        // Detecção 2: Literais óbvios (expect(true, true), expect(2, 2))
        if (_isObviousLiteral(actual, matcher)) {
          _addSmell(node, "Obvious literal comparison");
          return;
        }

        // Detecção 2.5: Literais sempre falsos (expect(true, false), expect(2, 3))
        if (_isAlwaysFalse(actual, matcher)) {
          _addSmell(node, "Always false assertion");
          return;
        }

        // Detecção 3: Verificações sempre verdadeiras
        if (_isAlwaysTrue(actual, matcher)) {
          _addSmell(node, "Always true assertion");
          return;
        }

        // Detecção 4: Variável atribuída imediatamente antes e testada sem transformação
        if (_testBlock != null &&
            _isImmediateAssignmentCheck(node, _testBlock!)) {
          _addSmell(node, "Immediate assignment check");
          return;
        }

        // Detecção 5: Construtor simples seguido de isNotNull
        if (_testBlock != null && _isConstructorNullCheck(node, _testBlock!)) {
          _addSmell(node, "Constructor null check");
          return;
        }
      }
    }
    super.visitExpressionStatement(node);
  }

  bool _isExpect(Statement stmt) {
    if (stmt is ExpressionStatement && stmt.expression is MethodInvocation) {
      final invocation = stmt.expression as MethodInvocation;
      return invocation.methodName.name == "expect";
    }
    return false;
  }

  bool _isTautology(Expression actual, Expression matcher) {
    final cleanMatcher = _unwrapMatcher(matcher);
    final actualSource = actual.toSource().trim();
    final matcherSource = cleanMatcher.toSource().trim();
    return actualSource == matcherSource;
  }

  bool _isObviousLiteral(Expression actual, Expression matcher) {
    final cleanMatcher = _unwrapMatcher(matcher);

    if (actual is BooleanLiteral && cleanMatcher is BooleanLiteral) {
      return actual.value == cleanMatcher.value;
    }

    if (actual is BooleanLiteral) {
      if (actual.value == true && _isMatcherTrue(matcher)) return true;
      if (actual.value == false && _isMatcherFalse(matcher)) return true;
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

  bool _isAlwaysFalse(Expression actual, Expression matcher) {
    final cleanMatcher = _unwrapMatcher(matcher);

    if (actual is BooleanLiteral && cleanMatcher is BooleanLiteral) {
      return actual.value != cleanMatcher.value;
    }
    if (actual is BooleanLiteral) {
      if (actual.value == true && _isMatcherFalse(matcher)) return true;
      if (actual.value == false && _isMatcherTrue(matcher)) return true;
    }
    if (actual is BooleanLiteral &&
        actual.value == false &&
        _isMatcherTrue(matcher)) {
      return true;
    }
    if (actual is IntegerLiteral && cleanMatcher is IntegerLiteral) {
      return actual.value != cleanMatcher.value;
    }
    if (actual is DoubleLiteral && cleanMatcher is DoubleLiteral) {
      return actual.value != cleanMatcher.value;
    }
    if (actual is StringLiteral && cleanMatcher is StringLiteral) {
      return actual.stringValue != cleanMatcher.stringValue;
    }
    return false;
  }

  bool _isAlwaysTrue(Expression actual, Expression matcher) {
    if (actual is BooleanLiteral && actual.value == true) return true;

    final cleanMatcher = _unwrapMatcher(matcher);
    if (cleanMatcher is BooleanLiteral && cleanMatcher.value == true) {
      final actualSource = actual.toSource();
      if (actualSource.contains('.is') &&
          _isObviousIdentityCheck(actualSource)) {
        return true;
      }
    }

    if (actual is BinaryExpression &&
        actual.operator.toString() == '!=' &&
        actual.rightOperand.toSource() == 'null') {
      return _wasJustAssigned(actual.leftOperand);
    }

    return false;
  }

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

  bool _isImmediateAssignmentCheck(ExpressionStatement e, Block testBlock) {
    final statements = testBlock.statements;
    final index = statements.indexOf(e);
    if (index <= 0) return false;

    final previousStmt = statements[index - 1];
    if (previousStmt is VariableDeclarationStatement) {
      final variables = previousStmt.variables.variables;
      for (var variable in variables) {
        final varName = variable.name.lexeme;
        final expectSource = e.toSource();
        if (expectSource.contains(varName) &&
            (expectSource.contains('!= null') ||
                expectSource.contains('isNotNull'))) {
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

  bool _isConstructorNullCheck(ExpressionStatement e, Block testBlock) {
    final statements = testBlock.statements;
    final index = statements.indexOf(e);
    final expectSource = e.toSource();

    if (!expectSource.contains('isNotNull') &&
        !expectSource.contains('!= null')) {
      return false;
    }

    final invocation = e.expression as MethodInvocation;
    final args = invocation.argumentList.arguments;
    if (args.isNotEmpty && args[0] is InstanceCreationExpression) {
      final constructorCall = args[0] as InstanceCreationExpression;
      if (!_hasComplexConstructorLogic(constructorCall)) return true;
    }

    for (int i = index - 1; i >= 0 && i >= index - 5; i--) {
      final stmt = statements[i];
      if (stmt is VariableDeclarationStatement) {
        final variables = stmt.variables.variables;
        for (var variable in variables) {
          final varName = variable.name.lexeme;
          if (expectSource.contains(varName)) {
            final initializer = variable.initializer;
            if (initializer is InstanceCreationExpression) {
              if (!_hasComplexConstructorLogic(initializer)) return true;
            }
          }
        }
      }
    }
    return false;
  }

  bool _hasTransformation(Expression expr) {
    if (expr is MethodInvocation) {
      final methodName = expr.methodName.name;
      final transformMethods = [
        'map',
        'where',
        'fold',
        'reduce',
        'toUpperCase',
        'toLowerCase',
        'trim',
        'split',
        'join',
        'substring',
        'replaceAll',
        'parse',
      ];
      return transformMethods.contains(methodName);
    }
    if (expr is BinaryExpression) {
      final operators = ['+', '-', '*', '/', '%', '??'];
      return operators.contains(expr.operator.toString());
    }
    return false;
  }

  bool _isMethodCallWithSideEffects(Expression expr) {
    if (expr is MethodInvocation) {
      final methodName = expr.methodName.name;
      final sideEffectMethods = [
        'fetch',
        'get',
        'post',
        'put',
        'delete',
        'load',
        'save',
        'calculate',
        'compute',
        'process',
        'validate',
        'parse',
      ];
      return sideEffectMethods.any((m) => methodName.contains(m));
    }
    return false;
  }

  bool _hasComplexConstructorLogic(InstanceCreationExpression creation) {
    final args = creation.argumentList.arguments;
    if (args.length > 3) return true;
    for (var arg in args) {
      if (arg is BinaryExpression ||
          arg is ConditionalExpression ||
          arg is MethodInvocation) {
        return true;
      }
    }
    return false;
  }

  bool _wasJustAssigned(Expression expr) {
    return expr is SimpleIdentifier;
  }

  Expression _unwrapMatcher(Expression matcher) {
    if (matcher is MethodInvocation) {
      final methodName = matcher.methodName.name;
      if (methodName == 'equals' && matcher.argumentList.arguments.isNotEmpty) {
        return matcher.argumentList.arguments.first;
      }
    }
    return matcher;
  }

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

  void _addSmell(ExpressionStatement e, String reason) {
    testSmells.add(
      TestSmell(
        name: testSmellName,
        testName: testName,
        path: testClass.path,
        projectName: testClass.projectName,
        moduleAtual: testClass.moduleAtual,
        commit: testClass.commit,
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
      ),
    );
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
