import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';

class AssertionRouletteDetector implements AbstractDetector {
  @override
  get testSmellName => "Assertion Roulette";
  int count = 0;

  var testsmellFirst;

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleStringLiteral &&
        e.parent is NamedExpression &&
        e.parent!.parent!.parent!.childEntities.firstOrNull!.toString() ==
            "expect") {
      if(count > 0) {
        if(count == 1) testSmells.add(testsmellFirst);
        count++;
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            start: testClass.lineNumber(e.offset),
            end: testClass.lineNumber(e.end)));
      }else{
        testsmellFirst = TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            start: testClass.lineNumber(e.offset),
            end: testClass.lineNumber(e.end));
        count++;
      }
    } else if (e is ArgumentList &&
        e.parent is MethodInvocation &&
        !e.toString().contains("reason:") &&
        e.parent!.childEntities.first.toString() == "expect") {
      if(count > 0) {
        if(count == 1) testSmells.add(testsmellFirst);
        count++;
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            start: testClass.lineNumber(e.offset),
            end: testClass.lineNumber(e.end)));
      }else{
        testsmellFirst = TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.parent!.parent!.toSource(),
            start: testClass.lineNumber(e.offset),
            end: testClass.lineNumber(e.end));
        count++;
      }
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _detect(e, testClass, testName));
    }
  }
}
