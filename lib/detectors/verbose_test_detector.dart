import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class VerboseTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Verbose Test";

  static const valueMaxLineVerbose = 30;

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _VerboseTestVisitor(
      testClass: testClass,
      testName: testName,
      testSmellName: testSmellName,
      codeTest: e.toSource(),
      startTest: testClass.lineNumber(e.offset),
      endTest: testClass.lineNumber(e.end),
    );
    e.accept(visitor);
    return visitor.testSmells;
  }

  @override
  String getDescription() {
    return '''
    The 'Verbose Test' test smell occurs when a test method is excessively long, 
    typically with more than 30 lines of code. Verbose test methods can indicate that 
    the method has multiple responsibilities, making it difficult to understand and maintain.
     Maintaining such test methods can be complicated, as changes in one part of the test can 
     affect other parts, increasing the likelihood of introducing errors.
    ''';
  }

  @override
  String getExample() {
    return '''
    test(
      "VerboseFixture",
      () => {
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3)
          });
    ''';
  }
}

/// Visitor específico para detectar testes verbose
class _VerboseTestVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _VerboseTestVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Verifica se é uma chamada de teste (test ou testWidgets)
    final methodName = node.methodName.name;
    if (methodName == 'test' || methodName == 'testWidgets') {
      final start = testClass.lineNumber(node.offset);
      final end = testClass.lineNumber(node.end);

      if (end - start > VerboseTestDetector.valueMaxLineVerbose) {
        testSmells.add(
          TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: node.toSource(),
            codeMD5: Util.md5(node.toSource()),
            codeTest: codeTest,
            codeTestMD5: Util.md5(codeTest),
            startTest: startTest,
            endTest: endTest,
            start: start,
            end: end,
            collumnStart: testClass.columnNumber(node.offset),
            collumnEnd: testClass.columnNumber(node.end),
            offset: node.offset,
            endOffset: node.end,
          ),
        );
      }
    }

    // Continua a recursão para outros nós
    super.visitMethodInvocation(node);
  }
}
