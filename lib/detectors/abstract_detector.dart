import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

abstract class AbstractDetector {
  String get testSmellName;
  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName);
}
