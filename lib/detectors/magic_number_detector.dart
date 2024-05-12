import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';

class MagicNumberDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is ForElement || e is IfElement || e is WhileStatement) return;

    if (e is IntegerLiteral || e is DoubleLiteral) {
      testSmells.add(TestSmell("Magic Number", testName, testClass, code: e.toSource(), start: testClass.lineNumber(e.offset), end: testClass.lineNumber(e.end)));
    } else {
      e.childEntities.whereType<AstNode>().forEach((e) => _detect(e, testClass, testName));
      // e.childEntities.forEach((element) {
      //   if (element is AstNode) {
      //     _magicNumber(element, testClass, testName);
      //   }
      // });
    }
  }

  @override
  String get testSmellName => "Magic Number";
}
