import 'package:dnose/detectors/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/detectors/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class ResourceOptimismDetector implements AbstractDetector{
  @override
  get testSmellName => "Detector Resource Optimism";

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is MethodInvocation && e.toSource().contains("File")) {
      testSmells.add(TestSmell(testSmellName, testName, testClass, code: e.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.forEach((e) {
        if (e is AstNode) _detect(e, testClass, testName);
      });
    }
  }
}