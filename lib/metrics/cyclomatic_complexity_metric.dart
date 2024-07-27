

import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

class CyclomaticComplexityMetric implements AbstractMetric{
  @override
  TestMetric calculate(ExpressionStatement e, TestClass testClass, String testName) {
    throw UnimplementedError();
  }

  @override
  String get metricName => "Cyclomatic Complexity";

}