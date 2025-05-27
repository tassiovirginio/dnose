import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class AssertionRouletteDetector implements AbstractDetector {
  @override
  get testSmellName => "Assertion Roulette";

  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  int cont = 0;
  int contWithReason = 0;

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
    if (e is ArgumentList &&
        e.parent is MethodInvocation &&
        !e.toString().contains("reason:") &&
        e.parent!.childEntities.first.toString() == "expect") {
          cont++;
      if ((cont == 1 && contWithReason == 1) || (cont > 1 && contWithReason == 0) ||
          (cont > 1 && contWithReason > 1)) {
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            codeMD5: Util.md5(e.parent!.parent!.toSource()),
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
      } else {
        cont++;
      }
    } else if (e is ArgumentList &&
        e.parent is MethodInvocation &&
        e.toString().contains("reason:") &&
        e.parent!.childEntities.first.toString() == "expect") {
      contWithReason++;

      if ((cont == 1 && contWithReason == 1) || (cont > 1 && contWithReason == 0) ||
          (cont > 1 && contWithReason > 1)) {
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            codeMD5: Util.md5(e.parent!.parent!.toSource()),
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
      } else {
        cont++;
      }
    }

    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }

  @override
  String getDescription() {
    return
      '''
      Occurs when a test method has multiple non-documented assertions. 
      Multiple assertion statements in a test method without a descriptive message 
      impacts readability/understandability/maintainability as it’s not possible to 
      understand the reason for the failure of the test.
      '''
      ;
  }

  @override
  String getExample() {
    return
      '''
      test("AssertionRoulet5", () {
    // 1
    expect(1 + 2, 3);
    expect(1 + 2, 3);
  });

  test("AssertionRoulet6", () {
    // 2
    expect(1 + 2, 3);
    expect(1 + 2, 3);
    expect(1 + 2, 3);
  });
      '''
    ;
  }


}
