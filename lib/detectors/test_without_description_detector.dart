import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class TestWithoutDescriptionDetector implements AbstractDetector {
  @override
  get testSmellName => "Test Without Description";

  String? codeTest;
  int startTest = 0, endTest = 0;

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(AstNode e, TestClass testClass, String testName) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);
    _detect(e, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleStringLiteral &&
        e.parent is ArgumentList &&
        e.parent!.parent is MethodInvocation &&
        e.value.trim().isEmpty &&
        e.parent!.parent!.toString().contains("test(")) {
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.parent!.parent!.toSource(),
          codeMD5: Util.md5(e.parent!.parent!.toSource()),
          codeTest: codeTest,
          codeTestMD5: Util.md5(codeTest!),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          offset: e.offset,
          endOffset: e.end
      ));
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _detect(e, testClass, testName));
    }
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
