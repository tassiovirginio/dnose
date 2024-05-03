import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

abstract class AbstractDetectorTestSmell {
  String get testSmellName;

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass);
}
