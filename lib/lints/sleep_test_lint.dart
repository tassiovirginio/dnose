import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class SleepTestLint extends DartLintRule {
  final Set<String> listTestNames = {
    "test",
    "testWidgets",
    "testWithGame",
    "isarTest"
  };

  static const valueMaxLineVerbose = 30;

  SleepTestLint() : super(code: _code);

  static const _code = LintCode(
    name: 'sleep_test_lint',
    problemMessage: 'This test function with sleep.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addExpressionStatement((node) {
      if (node.beginToken.type == TokenType.IDENTIFIER &&
          listTestNames.contains(node.beginToken.toString())) {
        verifyTestSmell(node, reporter);
      };
    });
  }

  void verifyTestSmell(node, reporter) {
    if (node.toSource().contains("sleep") == true &&
        node.toSource().contains("delayed") == false) {
      reporter.atNode(node, code);
    }
  }

}
