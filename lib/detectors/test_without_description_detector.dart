import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class TestWithoutDescriptionDetector implements AbstractDetector {
  @override
  get testSmellName => "Test Without Description";

  @override
  List<TestSmell> detect(AstNode e, TestClass testClass, String testName) {
    final visitor = _TestWithoutDescriptionVisitor(
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
    type of test smell that occurs when a test case lacks a description. In the example below,
    the test block lacks a description, which can result in a lack of
    understanding and difficulty in maintenance. It is relevant to provide clear and concise 
    descriptions for each test to ensure they are understandable and easy to maintain.
    ''';
  }

  @override
  String getExample() {
    return '''
    const sum = require('./sum');
    test('', () => {
    expect(sum(1, 2)).toBe(3);
    });
    ''';
  }
}

class _TestWithoutDescriptionVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _TestWithoutDescriptionVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final parent = node.parent;
    if (parent is ArgumentList &&
        parent.parent is MethodInvocation &&
        node.value.trim().isEmpty &&
        parent.parent!.toString().contains("test(")) {
      testSmells.add(
        TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: parent.parent!.toSource(),
          codeMD5: Util.md5(parent.parent!.toSource()),
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
    super.visitSimpleStringLiteral(node);
  }
}
