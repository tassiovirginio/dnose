import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class EmptyTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Empty Test";

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  int cont = 0;
  String code_1 = "";

  void _detect(AstNode e, TestClass testClass, String testName) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is Block &&
        e.parent is BlockFunctionBody &&
        e.parent!.parent is FunctionExpression &&
        e.parent!.parent!.parent!.parent is MethodInvocation &&
        e.parent!.parent!.parent!.parent!.childEntities.first.toString() ==
            "test" &&
        e.toString().replaceAll(" ", "") == "{}") {
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.toSource(),
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities
          .whereType<AstNode>()
          .forEach((e) => _detect(e, testClass, testName));
    }
  }
}
