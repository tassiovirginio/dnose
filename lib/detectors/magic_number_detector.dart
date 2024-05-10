import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';

class MagicNumberDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _magicNumber(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _magicNumber(AstNode e, TestClass testClass, String testName) {
    if (e is ForElement || e is IfElement || e is WhileStatement) {
      return;
    }
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is IntegerLiteral || e is DoubleLiteral) {
      testSmells.add(TestSmell("Magic Number", testName, testClass, code: e.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.forEach((element) {
        if (element is AstNode) {
          _magicNumber(element, testClass, testName);
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
