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
      if (cont > 0) {
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            codeMD5: Util.MD5(e.parent!.parent!.toSource()),
            start: testClass.lineNumber(e.offset),
            end: testClass.lineNumber(e.end),
            collumnStart: testClass.columnNumber(e.offset),
            collumnEnd: testClass.columnNumber(e.end),
            codeTest: codeTest,
            codeTestMD5: Util.MD5(codeTest!),
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
      cont++;
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _detect(e, testClass, testName));
    }
  }
}
