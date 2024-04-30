import 'package:analyzer/dart/ast/ast.dart';
import 'package:teste01/detectors/TestClass.dart';
import 'package:teste01/detectors/AbstractDetectorTestSmell.dart';
import 'package:teste01/detectors/TestSmell.dart';

class DetectorMagicNumber implements AbstractDetectorTestSmell {
  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    _magicNumber(e as AstNode, testClass);
    return testSmells;
  }

  void _magicNumber(AstNode e, TestClass testClass) {
    if (e is ForElement || e is IfElement) {
      return;
    }
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is IntegerLiteral || e is DoubleLiteral) {
      testSmells.add(TestSmell("Magic Number", testClass, code: e.toSource()));
    } else {
      e.childEntities.forEach((element) {
        if (element is AstNode) {
          _magicNumber(element, testClass);
        }
      });
    }
  }

  void detectar01(AstNode astnode) {
    if (astnode is ForElement || astnode is IfElement) {
      return;
    }
    if (astnode is VariableDeclaration) {
      print(astnode.runtimeType);
      print(astnode.toSource());
      print("---------------------------------------------------");
    }

    if (astnode.childEntities.isNotEmpty) {
      astnode.childEntities.forEach((element) {
        if (element is AstNode) {
          detectar01(element);
        }
      });
    }
  }

  @override
  String get testSmellName => "Magic Number";
}
