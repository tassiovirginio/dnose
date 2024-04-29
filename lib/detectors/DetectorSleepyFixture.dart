import 'package:teste01/TestClass.dart';
import 'package:teste01/detectors/AbstractDetectorTestSmell.dart';
import 'package:teste01/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorSleepyFixture implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Sleepy Fixture";

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    String codigo = e.toSource();
    if (codigo.contains("sleep")) {
      testSmells.add(TestSmell(testSmellName, testClass, code: codigo));
    }
    return testSmells;
  }
}