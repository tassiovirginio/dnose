import 'package:analyzer/dart/ast/ast.dart';
import 'package:teste01/TestClass.dart';
import 'package:teste01/detectors/AbstractDetectorTestSmell.dart';
import 'package:teste01/detectors/TestSmell.dart';

class DetectorConditionalTestLogic implements AbstractDetectorTestSmell {

  @override
  get testSmellName => "Conditional Test Logic";

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    String codigo = e.toSource();
    if (codigo.contains("if") ||
        codigo.contains("for") ||
        codigo.contains("while")) {
      testSmells.add(TestSmell(testSmellName, testClass, code: codigo));
    }
    return testSmells;
  }
}
