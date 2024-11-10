import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class TestWithoutDescriptionDetector implements AbstractDetector {
  @override
  get testSmellName => "Test Without Description";

  String? codeTest;
  int startTest = 0, endTest = 0;

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(AstNode e, TestClass testClass, String testName) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);
    _detect(e, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleStringLiteral &&
        e.parent is ArgumentList &&
        e.parent!.parent is MethodInvocation &&
        e.value.trim().isEmpty &&
        e.parent!.parent!.toString().contains("test(")) {
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.parent!.parent!.toSource(),
          codeTest: codeTest,
          codeTestMD5: Util.MD5(codeTest!),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _detect(e, testClass, testName));
    }
  }
}
