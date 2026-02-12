import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class SensitiveEqualityDetector implements AbstractDetector {
  @override
  get testSmellName => "Sensitive Equality";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _SensitiveEqualityVisitor(
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
    Occurs when the toString method is used within a test method. Test methods verify 
    objects by invoking the default toString() method of the object and comparing the output 
    against an specific string. Changes to the implementation of toString() might result in 
    failure. The correct approach is to implement a custom method within the object to perform this
     comparison.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Sensitive Equality1", () {
    String test = "teste";
    expect("teste", test.toString());
  });

  test("Sensitive Equality2", () {
    String test = "teste";
    expect("teste", test.toString());
  });

  test("Sensitive Equality3", () {
    String test = "teste";
    expect("teste", test.toLowerCase());
  });

  test("Sensitive Equality4", () {
    String test = "TESTE";
    expect("TESTE", test.toUpperCase());
  });
    ''';
  }
}

class _SensitiveEqualityVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _SensitiveEqualityVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final firstChild = node.childEntities.firstOrNull;
    final lastChild = node.childEntities.lastOrNull;

    if (firstChild is SimpleIdentifier &&
        firstChild.toString().trim() == "expect" &&
        lastChild != null &&
        lastChild.toString().contains(".toString()")) {
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
    super.visitMethodInvocation(node);
  }
}
