
import 'package:dnose/detectors/TestClass.dart';

class TestSmell{
  String? name;
  TestClass? testClass;
  String code = "";
  TestSmell(String name, TestClass testClass, {String code = ""}){
    this.name = name;
    this.testClass = testClass;
    this.code = code;
  }
}