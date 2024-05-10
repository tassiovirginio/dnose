import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DuplicateAssertDetector implements AbstractDetector{
  @override
  get testSmellName => "Duplicate Assert";

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  int cont = 0;
  String code_1 = "";

  void _detect(AstNode e, TestClass testClass, String testName) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is SimpleIdentifier) {
      if(e.toSource().trim() == "expect"){
        if(cont == 0){
          cont++;
          code_1 = e.toSource();
        }else if(cont == 1){
          cont++;
          testSmells.add(TestSmell(testSmellName, testName, testClass, code: e.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
        }
      }
    } else {
      e.childEntities.forEach((element) {
        if (element is AstNode) {
          _detect(element, testClass, testName);
        }
      });
    }
  }
}