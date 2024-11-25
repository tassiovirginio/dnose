import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class DuplicateAssertDetector implements AbstractDetector {
  @override
  get testSmellName => "Duplicate Assert";

  String? codeTest;
  int startTest = 0, endTest = 0;

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

  int cont = 0;
  List<String> list = [];

  void _detect(AstNode e, TestClass testClass, String testName) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is SimpleIdentifier) {
      if (e.toSource().trim() == "expect") {
        String lineString = e.parent!.parent!.toSource().replaceAll(" ", "");
        if (cont == 0) {
          cont++;
          list.add(lineString);
        } else if (cont >= 1 && list.contains(lineString)) {
          cont++;
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
              start: testClass.lineNumber(e.offset),
              end: testClass.lineNumber(e.end),
              collumnStart: testClass.columnNumber(e.offset),
              collumnEnd: testClass.columnNumber(e.end),
              offset: e.offset,
              endOffset: e.end
          ));
        }
      }
    }
    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }
}
