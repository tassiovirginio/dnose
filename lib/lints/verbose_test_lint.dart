import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class VerboseTestLint extends DartLintRule {
  final Set<String> listTestNames = {
    "test",
    "testWidgets",
    "testWithGame",
    "isarTest"
  };

  static const valueMaxLineVerbose = 30;

  VerboseTestLint() : super(code: _code);

  static const _code = LintCode(
    name: 'verbose_test_lint',
    problemMessage: 'Esta função de teste esta verbosa.',
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
        int start =
            lineNumber(node.root as CompilationUnit, node.parent!.offset);
        int end = lineNumber(node.root as CompilationUnit, node.parent!.end);

        if (end - start > valueMaxLineVerbose) {
          reporter.atNode(node, code);
        }
      }
      ;
    });
  }

  int lineNumber(CompilationUnit cu, int offset) =>
      cu.lineInfo.getLocation(offset).lineNumber;
}
