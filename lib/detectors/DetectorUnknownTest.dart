import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorUnknownTest implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Unknown Test";

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    if(e.toSource().contains("expect") == false){
      testSmells.add(TestSmell(
          testSmellName, testName, testClass, code: e.toSource(),
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end)));
    }
    return testSmells;
  }

}