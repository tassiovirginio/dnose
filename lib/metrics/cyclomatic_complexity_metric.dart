import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

//Base: https://github.com/bancolombia/dart-code-linter/blob/trunk/lib/src/analyzers/lint_analyzer/metrics/metrics_list/cyclomatic_complexity/cyclomatic_complexity_flow_visitor.dart
class CyclomaticComplexityMetric implements AbstractMetric {
  @override
  TestMetric calculate(
      ExpressionStatement e, TestClass testClass, String testName) {
    _calculate(e, testClass, testName);

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
    if (e is AssertStatement ||
    e is CatchClause ||
    e is ConditionalExpression ||
    e is ForStatement ||
    e is IfStatement ||
    e is SwitchCase ||
    e is SwitchDefault ||
    e is WhileStatement ||
    e is YieldStatement) {
      cont++;
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _calculate(e, testClass, testName));
    }
  }

  @override
  String get metricName => "Cyclomatic Complexity";
}
