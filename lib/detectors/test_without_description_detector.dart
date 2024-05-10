import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class TestWithoutDescriptionDetector implements AbstractDetector{
  @override
  get testSmellName => "Test Without Description";

  List<TestSmell> testSmells = List.empty(growable: true);

  // List<TestSmell> detect2(ExpressionStatement e, TestClass testClass) {
  //
  //   e.childEntities.forEach((element) {
  //   if (element is MethodInvocation) {
  //     element.childEntities.forEach((e2) {
  //       if (e2 is ArgumentList) {
  //         e2.childEntities.forEach((e3) {
  //           if (e3 is SimpleStringLiteral) {
  //             if (e3.value.trim().isEmpty) {
  //               testSmells.add(TestSmell("Test Without Description", testClass, code: e.toSource()));
  //             }
  //           }
  //         });
  //       }
  //     });
  //   }
  // });
  //   return testSmells;
  // }

  @override
  List<TestSmell> detect(AstNode e, TestClass testClass, String testName) {
    _detect(e, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleStringLiteral &&
        e.parent is ArgumentList &&
        e.parent!.parent is MethodInvocation &&
        e.value.trim().isEmpty &&
        e.parent!.parent!.toString().contains("test(")) {
      testSmells.add(TestSmell(testSmellName, testName, testClass, code: e.parent!.parent!.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.forEach((e) {
        if (e is AstNode) _detect(e, testClass, testName);
      });
    }
  }
}