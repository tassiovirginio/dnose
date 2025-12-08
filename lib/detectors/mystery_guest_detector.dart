import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class MysteryGuestDetector implements AbstractDetector {
  @override
  get testSmellName => "Mystery Guest";

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
    // Detect file reads like File('path').readAsStringSync() or similar
    if (e is MethodInvocation &&
        e.methodName.name == 'readAsStringSync' &&
        e.target is MethodInvocation &&
        (e.target as MethodInvocation).methodName.name == 'File') {
      // Check if the file path is a string literal (not a variable)
      var fileArgs = (e.target as MethodInvocation).argumentList.arguments;
      if (fileArgs.isNotEmpty && fileArgs.first is SimpleStringLiteral) {
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

    // Detect other potential mystery guests like database calls, external API calls, etc.
    // For now, focusing on file reads as per the example

    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }

  @override
  String getDescription() {
    return
      '''
      Occurs when a test depends on external data or states that are not explicitly visible in the test code.
      This creates implicit dependencies that make the test behavior difficult to understand and maintain.
      Examples include reading from files, databases, or external configurations without clear setup.
      '''
      ;
  }

  @override
  String getExample() {
    return
      '''
      test('Gift model test', () {
        final file = File('json/gift_test.json').readAsStringSync();
        final gifts = Gift.fromJson(jsonDecode(file) as Map<String, dynamic>);

        expect(gifts.id, 999);
      });

      // Better approach:
      test('Gift model test', () {
        final testData = '{"id": 999, "name": "Test Gift"}';
        final gifts = Gift.fromJson(jsonDecode(testData) as Map<String, dynamic>);

        expect(gifts.id, 999);
      });
      '''
    ;
  }
}
