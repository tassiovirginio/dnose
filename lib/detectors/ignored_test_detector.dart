import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class IgnoredTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Ignored Test";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _IgnoredTestVisitor(
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
    Testing in Dart offers developers the ability to suppress the execution of test methods. 
    However, these ignored test methods result in overhead, as they add unnecessary cost regarding 
    compilation time and increase code complexity and comprehension difficulty.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Some Test1", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:        true);

  test("Some Test2", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "Message Ignore");


  test("Some Test3", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "");

  test("Some Test4", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "     ");
    ''';
  }
}

class _IgnoredTestVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _IgnoredTestVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitNamedExpression(NamedExpression node) {
    final parent = node.parent;
    if (parent is ArgumentList) {
      final nodeStr = node.toString();
      if (nodeStr.contains("skip: true") ||
          nodeStr.contains("skip:true") ||
          nodeStr.contains("skip: ")) {
        final firstChild = node.childEntities.elementAtOrNull(0);
        final secondChild = node.childEntities.elementAtOrNull(1);
        if (firstChild != null &&
            firstChild is Label &&
            firstChild.toString() == "skip:" &&
            secondChild != null &&
            secondChild.toString() != "false") {
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
    }
    super.visitNamedExpression(node);
  }
}
