import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class ResidualStateTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Residual State";

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    for (var variable in node.variables.variables) {
      if (variable.initializer != null) {
        var initializer = variable.initializer!;

        if (_isDisposableObject(initializer)) {
          final variableName = variable.name.toString();
          final isStream = _isStreamController(initializer);

          if (!_hasCleanupCall(variableName, isStream)) {
            testSmells.add(createSmell(node));
          }
        }
      }
    }
    super.visitVariableDeclarationStatement(node);
  }

  bool _isDisposableObject(Expression expr) {
    var source = expr.toSource();
    return source.contains('TextEditingController(') ||
        source.contains('StreamController') ||
        source.contains('AnimationController(') ||
        source.contains('FocusNode(') ||
        source.contains('TabController(');
  }

  bool _isStreamController(Expression expr) {
    var source = expr.toSource();
    return source.contains('StreamController');
  }

  bool _hasCleanupCall(String variableName, bool isStream) {
    if (isStream) {
      return codeTest.contains('$variableName.close()') ||
          codeTest.contains('$variableName.close();');
    } else {
      return codeTest.contains('$variableName.dispose()') ||
          codeTest.contains('$variableName.dispose();');
    }
  }

  @override
  String getDescription() {
    return '''
      Occurs when tests leave residual state in components or services, such as widgets
      or state management instances. This can lead to intermittent failures, unreliable tests,
      or unexpected dependencies between test cases. Common issues include not calling
      dispose() on controllers or not properly cleaning up resources.
      ''';
  }

  @override
  String getExample() {
    return '''
      // Problematic example:
      testWidgets('Test with residual state', (WidgetTester tester) async {
        final controller = TextEditingController(); // Created but not disposed
        await tester.pumpWidget(TextField(controller: controller));
        // Test ends without controller.dispose()
      });

      // Correct example:
      testWidgets('Test without residual state', (WidgetTester tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(TextField(controller: controller));
        controller.dispose(); // Properly disposed
      });
      ''';
  }
}
