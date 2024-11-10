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
  String code_1 = "";

  void _detect(AstNode e, TestClass testClass, String testName) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is SimpleIdentifier) {
      if (e.toSource().trim() == "expect") {
        if (cont == 0) {
          cont++;
          code_1 = e.toSource();
        } else if (cont == 1) {
          cont++;
          testSmells.add(TestSmell(
              name: testSmellName,
              testName: testName,
              testClass: testClass,
              code: e.toSource(),
              codeTest: codeTest,
              codeTestMD5: Util.MD5(codeTest!),
              startTest: startTest,
              endTest: endTest,
              start: testClass.lineNumber(e.offset),
              end: testClass.lineNumber(e.end)));
        }
      }
    }
    e.childEntities
        .whereType<AstNode>()
        .forEach((e) => _detect(e, testClass, testName));
  }
}
