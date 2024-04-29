import 'package:teste01/detectors/TestClass.dart';
import 'package:teste01/detectors/TestSmell.dart';
import 'package:analyzer/dart/ast/ast.dart';

abstract class AbstractDetectorTestSmell {
  String get testSmellName;

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass);
}
