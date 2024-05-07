
import 'package:dnose/detectors/TestClass.dart';

class TestSmell{
  String? name;
  String? testName;
  TestClass? testClass;
  String code = "";
  int? start;
  int? end;
  TestSmell(String name,String testName, TestClass testClass, {String code = "", int? start, int? end}){
    this.name = name;
    this.testName = testName;
    this.testClass = testClass;
    this.code = code;
    this.start = start;
    this.end = end;
  }
}