import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class SleepyFixtureDetector implements AbstractDetector{
  @override
  get testSmellName => "Sleepy Fixture";

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  //MethodInvocationImpl
  // sleep(Duration(seconds: UM_SEGUNDO))
  // SimpleIdentifierImpl
  // sleep

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleIdentifier &&
        e.name == "sleep" &&
        e.parent is MethodInvocation) {
      testSmells.add(TestSmell(testSmellName, testName, testClass, code: e.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.forEach((e) {
        if (e is AstNode) _detect(e, testClass, testName);
      });
    }
  }
}