import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ResidualStateTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Residual State Test";

  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    // Detect creation of objects that need dispose without proper cleanup
    if (e is VariableDeclarationStatement) {
      for (var variable in e.variables.variables) {
        if (variable.initializer != null) {
          var initializer = variable.initializer!;
          if (_isDisposableObject(initializer)) {
            // Check if dispose() is called in the same test
            if (!_hasDisposeCall(e, variable.name.toString())) {
              testSmells.add(TestSmell(
                  name: testSmellName,
                  testName: testName,
                  testClass: testClass,
                  code: e.toSource(),
                  codeMD5: Util.md5(e.toSource()),
                  start: testClass.lineNumber(e.offset),
                  end: testClass.lineNumber(e.end),
                  collumnStart: testClass.columnNumber(e.offset),
                  collumnEnd: testClass.columnNumber(e.end),
                  codeTest: codeTest,
                  codeTestMD5: Util.md5(codeTest!),
                  startTest: startTest,
                  endTest: endTest,
                  offset: e.offset,
                  endOffset: e.end));
            }
          }
        }
      }
    }

    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }

  bool _isDisposableObject(Expression expr) {
    // Check for common disposable objects in Flutter tests
    var source = expr.toSource();
    return source.contains('TextEditingController(') ||
           source.contains('StreamController(') ||
           source.contains('AnimationController(') ||
           source.contains('FocusNode(') ||
           source.contains('TabController(');
  }

  bool _hasDisposeCall(AstNode testNode, String variableName) {
    // Check if dispose() is called on the variable within the test
    var testSource = testNode.toSource();
    return testSource.contains('$variableName.dispose()') ||
           testSource.contains('$variableName.dispose();');
  }

  @override
  String getDescription() {
    return
      '''
      Occurs when tests leave residual state in components or services, such as widgets
      or state management instances. This can lead to intermittent failures, unreliable tests,
      or unexpected dependencies between test cases. Common issues include not calling
      dispose() on controllers or not properly cleaning up resources.
      '''
      ;
  }

  @override
  String getExample() {
    return
      '''
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
      '''
    ;
  }
}
