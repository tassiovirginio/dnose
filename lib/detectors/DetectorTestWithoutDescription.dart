import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class DetectorTestWithoutDescription implements AbstractDetectorTestSmell{
  @override
  get testSmellName => "Test Without Description";

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    e.childEntities.forEach((element) {
    if (element is MethodInvocation) {
      element.childEntities.forEach((e2) {
        if (e2 is ArgumentList) {
          e2.childEntities.forEach((e3) {
            if (e3 is SimpleStringLiteral) {
              if (e3.value.trim().isEmpty) {
                testSmells.add(TestSmell("Test Without Description", testClass, code: e.toSource()));
              }
            }
          });
        }
      });
    }
  });
    return testSmells;
  }
}