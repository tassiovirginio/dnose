import 'package:analyzer/dart/ast/ast.dart' show ExpressionStatement;
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

class LinesOfCodeMetric implements AbstractMetric {
  @override
  TestMetric calculate(
      ExpressionStatement e, TestClass testClass, String testName) {
    int start = testClass.lineNumber(e.offset);
    int end = testClass.lineNumber(e.end);

    TestMetric testMetric = TestMetric(
              name: metricName,
              testName: testName,
              testClass: testClass,
              code: e.toSource(),
              start: testClass.lineNumber(e.offset),
              end: testClass.lineNumber(e.end),
              value: end - start);

    return testMetric;
  }

  @override
  String get metricName => "Lines Of Code";
}
