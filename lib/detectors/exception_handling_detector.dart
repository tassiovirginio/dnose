import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ExceptionHandlingDetector implements AbstractDetector {
  @override
  get testSmellName => "Exception Handling";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _ExceptionHandlingVisitor(
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
    This smell occurs when a test method explicitly a passing or failing of a test method 
    is dependent on the production method throwing an exception. Developers should utilize 
    JUnit's exception handling to automatically pass/fail the test instead of writing custom 
    exception handling code or throwing an exception.
    ''';
  }

  @override
  String getExample() {
    return '''
    void testFunction() {
    throw Exception("Erro");
  }

  test("Exception Handling1", () {
    //2
    try {
      throw Exception("Erro");
    } catch (e) {
      print(e);
    }
  });

  test("Exception Handling2", () {
    //1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    }
  });

  test("Exception Handling3", () {
    //1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    } finally {
      print("erro");
    }
  });
    ''';
  }
}

class _ExceptionHandlingVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _ExceptionHandlingVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitThrowExpression(ThrowExpression node) {
    _addSmell(node);
    super.visitThrowExpression(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    _addSmell(node);
    super.visitTryStatement(node);
  }

  void _addSmell(AstNode node) {
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
        start: testClass.lineNumber(node.offset),
        end: testClass.lineNumber(node.end),
        collumnStart: testClass.columnNumber(node.offset),
        collumnEnd: testClass.columnNumber(node.end),
        offset: node.offset,
        endOffset: node.end,
      ),
    );
  }
}
