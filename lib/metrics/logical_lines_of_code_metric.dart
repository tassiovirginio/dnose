import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';

class LogicalLinesOfCodeMetric implements AbstractMetric {
  int _lloc = 0;

  @override
  TestMetric calculate(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    _lloc = 0;
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
      value: _lloc,
    );

    return testMetric;
  }

  void _calculate(AstNode e) {
    // Count statements, ignoring blocks and empty statements.
    if (e is Statement && e is! Block && e is! EmptyStatement) {
      _lloc++;
    }

    // Also consider Variable declarations as logical lines if they are not already counted by a Statement
    if (e is VariableDeclarationList &&
        e.parent is! VariableDeclarationStatement) {
      _lloc++;
    }

    e.childEntities.whereType<AstNode>().forEach((child) => _calculate(child));
  }

  @override
  String get metricName => "Logical Lines Of Code";
}
