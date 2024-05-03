import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorResourceOptimism implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Detector Resource Optimism";

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    String codigo = e.toSource();
    String codigo2 = codigo.replaceAll(" ", "");
    if (codigo2.contains("=File(")) {
      testSmells.add(TestSmell(testSmellName, testClass, code: codigo));
    }
    return testSmells;
  }
}