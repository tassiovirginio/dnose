import 'package:analyzer/dart/ast/ast.dart';
import 'package:teste01/TestClass.dart';
import 'package:teste01/detectors/AbstractDetectorTestSmell.dart';
import 'package:teste01/detectors/TestSmell.dart';

class DetectorMagicNumber implements AbstractDetectorTestSmell{
  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    _magicNumber(e as AstNode, testClass);
    return testSmells;
  }

  void _magicNumber(AstNode e, TestClass testClass) {//Melhorar - encontrar somente quando setado em uma variável
  if (e is IntegerLiteral || e is DoubleLiteral) {
    TestSmell testSmell = TestSmell("Magic Number", testClass);
    testSmell.code = e.toSource();
    testSmells.add(testSmell);
  } else {
    e.childEntities.forEach((element) {
      if (element is AstNode) {
        _magicNumber(element,testClass);
      }
    });
  }
}

  @override
  String get testSmellName =>"Magic Number";

}