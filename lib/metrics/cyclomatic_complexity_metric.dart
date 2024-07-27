

import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

class CyclomaticComplexityMetric implements AbstractMetric{
  @override
  TestMetric calculate(ExpressionStatement e, TestClass testClass, String testName) {
    _calculate(e,testClass,testName);

    TestMetric testMetric = TestMetric(
        name: metricName,
        testName: testName,
        testClass: testClass,
        code: e.toSource(),
        start: testClass.lineNumber(e.offset),
        end: testClass.lineNumber(e.end),
        value: cont + 1);

    return testMetric;
  }

  int cont = 0;

  void _calculate(AstNode e, TestClass testClass, String testName) {
    if (e is ForElement || e is IfElement || e is WhileStatement || e is SwitchStatement) {
      cont ++;
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _calculate(e, testClass, testName));
    }
  }

  @override
  String get metricName => "Cyclomatic Complexity";

}