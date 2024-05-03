import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorDuplicateAssert implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Duplicate Assert";

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    _detect(e as AstNode, testClass);
    return testSmells;
  }

  int cont = 0;
  String code_1 = "";

  void _detect(AstNode e, TestClass testClass) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is SimpleIdentifier) {
      if(e.toSource().trim() == "expect"){
        if(cont == 0){
          cont++;
          code_1 = e.toSource();
        }else if(cont == 1){
          cont++;
          testSmells.add(TestSmell(testSmellName, testClass, code: e.toSource() + "\n" + code_1));    
        }
      }
    } else {
      e.childEntities.forEach((element) {
        if (element is AstNode) {
          _detect(element, testClass);
        }
      });
    }
  }
}