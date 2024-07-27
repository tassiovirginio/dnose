import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

mixin AbstractMetric {
  String get metricName;

  TestMetric calculate(
      ExpressionStatement e, TestClass testClass, String testName);
}
