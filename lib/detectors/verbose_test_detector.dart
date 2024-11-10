import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class VerboseTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Verbose Test";

  String? codeTest;
  int startTest = 0, endTest = 0;

  static const valueMaxLineVerbose = 30;

  List<TestSmell> testSmells = List.empty(growable: true);

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
        e.toString() == "test" &&
        e.parent is MethodInvocation) {
      int start = lineNumber(e.root as CompilationUnit, e.parent!.offset);
      int end = lineNumber(e.root as CompilationUnit, e.parent!.end);

      if (end - start > valueMaxLineVerbose) {
        testSmells.add(TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.toSource(),
            codeMD5: Util.MD5(e.toSource()),
            codeTest: codeTest,
            codeTestMD5: Util.MD5(codeTest!),
            startTest: startTest,
            endTest: endTest,
            start: testClass.lineNumber(e.parent!.offset),
            end: testClass.lineNumber(e.parent!.end),
            collumnStart: testClass.columnNumber(e.offset),
            collumnEnd: testClass.columnNumber(e.end),
            offset: e.offset,
            endOffset: e.end
        ));
      }
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _detect(e, testClass, testName));
    }
  }

  int lineNumber(CompilationUnit cu, int offset) =>
      cu.lineInfo.getLocation(offset).lineNumber;
}
