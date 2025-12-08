import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';

mixin AbstractDetector {
  String get testSmellName;

  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  );

  String getDescription();

  String getExample();
}
