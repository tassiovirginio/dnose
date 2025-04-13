import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UnknownTestLint extends DartLintRule {
  final Set<String> listTestNames = {
    "test",
    "testWidgets",
    "testWithGame",
    "isarTest"
  };


  UnknownTestLint() : super(code: _code);

  static const _code = LintCode(
    name: 'unknown_test_lint',
    problemMessage: 'This test function is unkdown.',
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
      }
      ;
    });
  }

  void verifyTestSmell(node, reporter) {
    if (node.toSource().contains("expect") == false &&
        node.toSource().contains("expectLater") == false &&
        node.toSource().contains("verify") == false &&
        node.toSource().contains("assert") == false) {
      reporter.atNode(node, code);
    }
  }

}
