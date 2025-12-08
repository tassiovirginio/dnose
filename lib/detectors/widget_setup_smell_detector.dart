import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class WidgetSetupSmellDetector implements AbstractDetector {
  @override
  get testSmellName => "Widget Setup Smell";

  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  List<String> pumpWidgetCalls = [];

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);
    pumpWidgetCalls.clear();
    _detect(e as AstNode, testClass, testName);

    // Check for repeated widget setups
    if (pumpWidgetCalls.length > 1) {
      // Group similar setups
      Map<String, int> setupCounts = {};
      for (var call in pumpWidgetCalls) {
        // Simplify the call for comparison (remove specific content)
        var simplified = _simplifyPumpWidgetCall(call);
        setupCounts[simplified] = (setupCounts[simplified] ?? 0) + 1;
      }

      // If any setup is repeated more than once, flag it
      for (var entry in setupCounts.entries) {
        if (entry.value > 1) {
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
          break; // Flag once per test
        }
      }
    }

    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is MethodInvocation && e.methodName.toString() == 'pumpWidget') {
      pumpWidgetCalls.add(e.toSource());
    }

    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }

  String _simplifyPumpWidgetCall(String call) {
    // Remove specific content to detect structural similarity
    // For example, replace specific text content with placeholders
    return call
        .replaceAll(RegExp(r"'[^']*'"), "'TEXT'")
        .replaceAll(RegExp(r'"[^"]*"'), '"TEXT"');
  }

  @override
  String getDescription() {
    return
      '''
      Occurs when widget setups are repeated unnecessarily across multiple tests.
      This increases complexity, reduces code clarity, and makes maintenance difficult.
      Common setups like MaterialApp and Scaffold configurations should be extracted
      into helper methods or utilities.
      '''
      ;
  }

  @override
  String getExample() {
    return
      '''
      // Problematic example:
      testWidgets('Test 1', (tester) async {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text('Test 1'))));
      });
      testWidgets('Test 2', (tester) async {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text('Test 2'))));
      });

      // Better example:
      Widget buildTestWidget(Widget child) => MaterialApp(home: Scaffold(body: child));

      testWidgets('Test 1', (tester) async {
        await tester.pumpWidget(buildTestWidget(Text('Test 1')));
      });
      testWidgets('Test 2', (tester) async {
        await tester.pumpWidget(buildTestWidget(Text('Test 2')));
      });
      '''
    ;
  }
}
