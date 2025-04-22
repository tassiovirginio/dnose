import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class EmptyTestLint extends DartLintRule {
  final Set<String> listTestNames = {
    "test",
    "testWidgets",
    "testWithGame",
    "isarTest"
  };

  EmptyTestLint() : super(code: _code);

  static const _code = LintCode(
    name: 'empty_test_lint',
    problemMessage: 'This test function is empty.',
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
    });
  }

  void verifyTestSmell(node, reporter) {
    if ( node.childEntities.first.toString() == "test" 
    // &&
          // (node.toString().replaceAll(" ", "") == "()=>{}" ||
          //     node.toString().replaceAll(" ", "") == "{}" ||
          //     node.toString().replaceAll(" ", "") == "(){}")
              ) {
        reporter.atNode(node, code);
      }
  }

}
