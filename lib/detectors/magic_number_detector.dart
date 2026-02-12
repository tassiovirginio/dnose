import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class MagicNumberDetector implements AbstractDetector {
  @override
  get testSmellName => "Magic Number";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _MagicNumberVisitor(
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
    Occurs when assert statements in a test method contain numeric literals (i.e., magic numbers) 
    as parameters. Magic numbers do not indicate the meaning/purpose of the number. Hence, they 
    should be replaced with constants or variables, thereby providing a descriptive name for the input.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Magic Number1", () => {expect(1 + 2, 3)}); //3

  test("Magic Number2", () => {expect("3", "3")}); //2

  test("Magic Number4", () {
    //1
    print(123);
  });

  test("Magic Number5", () {
    //1
    print("123");
  });
    ''';
  }
}

class _MagicNumberVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _MagicNumberVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    if (!_isInForOrNamedExpression(node)) {
      _addSmell(node);
    }
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    if (!_isInForOrNamedExpression(node)) {
      _addSmell(node);
    }
    super.visitDoubleLiteral(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final value = node.value.replaceAll('"', '');
    if (value.contains(RegExp(r'^\d+$')) && !_isInForOrNamedExpression(node)) {
      _addSmell(node);
    }
    super.visitSimpleStringLiteral(node);
  }

  bool _isInForOrNamedExpression(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ForPartsWithDeclarations || current is NamedExpression) {
        return true;
      }
      current = current.parent;
    }
    return false;
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
