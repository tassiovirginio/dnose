import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorSleepyFixture implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Sleepy Fixture";

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    _detect(e as AstNode, testClass);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass) {
    if (e is MethodInvocation && e.toSource().contains("sleep")) {
      testSmells.add(TestSmell(testSmellName, testClass, code: e.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.forEach((e) {
        if (e is AstNode) _detect(e, testClass);
      });
    }
  }
}