import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/detectors/models/test_smell.dart';

class PrintStatmentFixtureDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  String get testSmellName => "Print Statment Fixture";

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleIdentifier &&
        e.name == "print" &&
        e.parent is MethodInvocation) {
      testSmells.add(TestSmell(testSmellName, testName, testClass, code: e.parent!.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.forEach((e) {
        if (e is AstNode) _detect(e, testClass, testName);
      });
    }
  }
}
