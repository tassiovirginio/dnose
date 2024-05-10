import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class UnknownTestDetector implements AbstractDetector{
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