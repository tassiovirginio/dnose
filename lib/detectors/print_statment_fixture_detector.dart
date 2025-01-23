import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class PrintStatmentFixtureDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  @override
  String get testSmellName => "Print Statment Fixture";

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
    if (e is SimpleIdentifier &&
        ( (e.name == "print" && e.parent.toString().contains(".print") == false) ||
            (e.name == "write" &&
                (e.parent?.beginToken.toString() == "stdout" ||
                    e.parent?.beginToken.toString() == "stderr")) ||
            (e.name == "prints" && e.parent.toString().contains(".print") == false) ||
            (e.name == "writeln" &&
                (e.parent?.beginToken.toString() == "stdout" ||
                    e.parent?.beginToken.toString() == "stderr"))) &&
        e.parent is MethodInvocation) {
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.parent!.toSource(),
          codeMD5: Util.MD5(e.parent!.toSource()),
          codeTest: codeTest,
          codeTestMD5: Util.MD5(codeTest!),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          offset: e.offset,
          endOffset: e.end));
    }
    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }
}
