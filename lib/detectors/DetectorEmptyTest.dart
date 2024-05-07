import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorEmptyTest implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Empty Test";

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  int cont = 0;
  String code_1 = "";

  void _detect(AstNode e, TestClass testClass, String testName) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is SetOrMapLiteral && e.toString().replaceAll(" ", "") == "{}") {
      testSmells.add(TestSmell(
          testSmellName, testName, testClass, code: e.toSource(),
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end)));
    }else {
      e.childEntities.forEach((element) {
        if (element is AstNode) {
          _detect(element, testClass, testName);
        }
      });
    }
  }
}