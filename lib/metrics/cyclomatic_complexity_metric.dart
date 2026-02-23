import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

//Base: https://github.com/bancolombia/dart-code-linter/blob/trunk/lib/src/analyzers/lint_analyzer/metrics/metrics_list/cyclomatic_complexity/cyclomatic_complexity_flow_visitor.dart
class CyclomaticComplexityMetric implements AbstractMetric {
  @override
  TestMetric calculate(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    cont = 0;
    _calculate(e);

    TestMetric testMetric = TestMetric(
      name: metricName,
      testName: testName,
      path: testClass.path,
      projectName: testClass.projectName,
      moduleAtual: testClass.moduleAtual,
      commit: testClass.commit,
      code: e.toSource(),
      start: testClass.lineNumber(e.offset),
      end: testClass.lineNumber(e.end),
      value: cont + 1,
    );

    return testMetric;
  }

  int cont = 0;

  void _calculate(AstNode e) {
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
    } else if (e is BinaryExpression) {
      final operator = e.operator.lexeme;
      if (operator == '&&' || operator == '||' || operator == '??') {
        cont++;
      }
    }
    e.childEntities.whereType<AstNode>().forEach((e) => _calculate(e));
  }

  @override
  String get metricName => "Cyclomatic Complexity";
}
