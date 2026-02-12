import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class UnknownTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Unknown Test";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final codeTest = e.toSource();
    final startTest = testClass.lineNumber(e.offset);
    final endTest = testClass.lineNumber(e.end);

    // Collect all method invocations
    List<MethodInvocation> collectMethodInvocations(AstNode node) {
      final result = <MethodInvocation>[];
      if (node is MethodInvocation &&
          (node.methodName.name == "expect" ||
              node.methodName.name == "expectLater" ||
              node.methodName.name == "assert")) {
        result.add(node);
      }
      for (final child in node.childEntities.whereType<AstNode>()) {
        result.addAll(collectMethodInvocations(child));
      }
      return result;
    }

    final assertions = collectMethodInvocations(e);

    if (assertions.isEmpty) {
      return [
        TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.toSource(),
          codeMD5: Util.md5(e.toSource()),
          codeTest: codeTest,
          codeTestMD5: Util.md5(codeTest),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          offset: e.offset,
          endOffset: e.end,
        ),
      ];
    }

    return [];
  }

  @override
  String getDescription() {
    return '''
    An assertion statement is used to declare an expected boolean condition for a test method.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("UnknownTest1", () {
    print("teste");
  });

  test("UnknownTest2", () {
    print("teste");
    if(true){
      print("teste");
    }
  });

  test("UnknownTest4", () {
    print("teste");
    if(true){
      print("teste");
    }
    // expect(1, 1, reason: "teste");
  });
    ''';
  }
}
