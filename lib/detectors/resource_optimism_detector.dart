import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';

class ResourceOptimismDetector implements AbstractDetector {
  @override
  get testSmellName => "Resource Optimism";

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is MethodInvocation && e.toSource().replaceAll(" ", "").contains("File(")) {
      if( (e.toSource().contains("exists(") ||e.toSource().contains("existsSync(")) == false) {
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.toSource(),
            start: testClass.lineNumber(e.offset),
            end: testClass.lineNumber(e.end)));
      }
    }else{
      e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
    }
    
  }
}
