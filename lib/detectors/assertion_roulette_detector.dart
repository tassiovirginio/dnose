import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class AssertionRouletteDetector extends AbstractDetector {
  @override
  get testSmellName => "Assertion Roulette";

  int _cont = 0;
  int _contWithReason = 0;

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    _cont = 0;
    _contWithReason = 0;
    return super.detect(e, testClass, testName);
  }

  @override
  void visitArgumentList(ArgumentList node) {
    if (node.parent is MethodInvocation &&
        node.parent!.childEntities.first.toString() == "expect") {
      if (!node.toString().contains("reason:")) {
        _cont++;
        if ((_cont == 1 && _contWithReason == 1) ||
            (_cont > 1 && _contWithReason == 0) ||
            (_cont > 1 && _contWithReason > 1)) {
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
              start: testClass.lineNumber(node.offset),
              end: testClass.lineNumber(node.end),
              collumnStart: testClass.columnNumber(node.offset),
              collumnEnd: testClass.columnNumber(node.end),
              codeTest: codeTest,
              codeTestMD5: Util.md5(codeTest),
              startTest: startTest,
              endTest: endTest,
              offset: node.offset,
              endOffset: node.end,
            ),
          );
        } else {
          _cont++;
        }
      } else {
        _contWithReason++;
        if ((_cont == 1 && _contWithReason == 1) ||
            (_cont > 1 && _contWithReason == 0) ||
            (_cont > 1 && _contWithReason > 1)) {
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
              start: testClass.lineNumber(node.offset),
              end: testClass.lineNumber(node.end),
              collumnStart: testClass.columnNumber(node.offset),
              collumnEnd: testClass.columnNumber(node.end),
              codeTest: codeTest,
              codeTestMD5: Util.md5(codeTest),
              startTest: startTest,
              endTest: endTest,
              offset: node.offset,
              endOffset: node.end,
            ),
          );
        } else {
          _cont++;
        }
      }
    }
    super.visitArgumentList(node);
  }

  @override
  String getDescription() {
    return '''
      Occurs when a test method has multiple non-documented assertions. 
      Multiple assertion statements in a test method without a descriptive message 
      impacts readability/understandability/maintainability as it's not possible to 
      understand the reason for the failure of the test.
      ''';
  }

  @override
  String getExample() {
    return '''
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
      ''';
  }
}
