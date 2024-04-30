import 'package:analyzer/dart/ast/ast.dart';
import 'package:teste01/detectors/TestClass.dart';
import 'package:teste01/detectors/AbstractDetectorTestSmell.dart';
import 'package:teste01/detectors/TestSmell.dart';

class DetectorPrintStatmentFixture implements AbstractDetectorTestSmell {

  @override
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    String codigo = e.toSource();
    if (codigo.contains("print(")) {
      testSmells.add(TestSmell("PrintStatmentFixture", testClass, code: codigo));
    }
    return testSmells;
  }

  @override
  String get testSmellName => "Print Statment Fixture";
}
