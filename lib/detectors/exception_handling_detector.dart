import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';

class ExceptionHandlingDetector implements AbstractDetector {
  @override
  get testSmellName => "Exception Handling";

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is CatchClause || e is ThrowExpression || e is TryStatement) {
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.toSource(),
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end)));
    }
    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }
}
