import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class TestWithoutDescriptionDetector extends AbstractDetector {
  @override
  get testSmellName => "Test Without Description";

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.parent is ArgumentList &&
        node.parent!.parent is MethodInvocation &&
        node.value.trim().isEmpty &&
        node.parent!.parent!.toString().contains("test(")) {
      testSmells.add(
        TestSmell(
          name: testSmellName,
          testName: testName,
          path: testClass.path,
          projectName: testClass.projectName,
          moduleAtual: testClass.moduleAtual,
          commit: testClass.commit,
          code: node.parent!.parent!.toSource(),
          codeMD5: Util.md5(node.parent!.parent!.toSource()),
          codeTest: codeTest,
          codeTestMD5: Util.md5(codeTest),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(node.offset),
          end: testClass.lineNumber(node.end),
          collumnStart: testClass.columnNumber(node.offset),
          collumnEnd: testClass.columnNumber(node.end),
          offset: node.offset,
          endOffset: node.end,
        ),
      );
      // Don't recurse (preserving original else-branch behavior)
      return;
    }
    super.visitSimpleStringLiteral(node);
  }

  @override
  String getDescription() {
    return '''
    type of test smell that occurs when a test case lacks a description. In the example below,
    the test block lacks a description, which can result in a lack of
    understanding and difficulty in maintenance. It is relevant to provide clear and concise 
    descriptions for each test to ensure they are understandable and easy to maintain.
    ''';
  }

  @override
  String getExample() {
    return '''
    const sum = require('./sum');
    test('', () => {
    expect(sum(1, 2)).toBe(3);
    });
    ''';
  }
}
