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

    final block = _getParentBlock(e);
    if (block == null) return testSmells;

    final statements = block.statements;

    // Localiza a posição do expect atual
    final index = statements.indexOf(e);
    if (index == -1 || index == statements.length - 1) return testSmells;

    // procura o próximo expect
    for (int i = index + 1; i < statements.length; i++) {
      final stmt = statements[i];

      // Se achar outro expect
      if (_isExpect(stmt)) {
        final currentAssert = e.toSource();
        final nextAssert = stmt.toSource();

        // Assertions precisam ser idênticos
        if (currentAssert == nextAssert) {
          // Verifica se houve algo entre eles
          if (!_hasStateChangeBetween(statements, index, i)) {
            testSmells.add(
              TestSmell(
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
              ),
            );
          }
        }
        break; // só compara com o próximo expect
      }

      // Se achar algo que mude o estado → NÃO É REDUNDANTE
      if (_stateChanging(stmt)) break;
    }

    return testSmells;
  }

  // Identifica se é um expect(...)
  bool _isExpect(Statement stmt) {
    if (stmt is ExpressionStatement &&  stmt.expression is MethodInvocation) {
      final invocation = stmt.expression as MethodInvocation;
      return invocation.methodName.name == "expect";
    }
    return false;
  }

  // Identifica mudanças de estado entre dois expects
  bool _stateChanging(Statement stmt) {
    final expr = stmt is ExpressionStatement ? stmt.expression : null;

    return stmt is VariableDeclarationStatement ||
        stmt is ForStatement ||
        stmt is WhileStatement ||
        stmt is DoStatement ||
        stmt is IfStatement ||
        stmt is ReturnStatement ||
        expr is MethodInvocation ||
        expr is AssignmentExpression ||
        expr is AwaitExpression;
  }

  // Verifica se houve qualquer ação entre dois expects
  bool _hasStateChangeBetween(
      List<Statement> statements, int start, int end) {
    for (int i = start + 1; i < end; i++) {
      if (_stateChanging(statements[i])) {
        return true;
      }
    }
    return false;
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
Occurs when identical assertions are executed consecutively without any state-changing
operation between them. True redundant assertions reduce test clarity and maintainability.
''';
  }

  @override
  String getExample() {
    return '''
// Redundant:
expect(value, 10);
expect(value, 10); // redundant (no state change)

// Valid:
expect(a, 1);
pump();
expect(a, 1); // NOT redundant (state changed)
''';
  }
}
