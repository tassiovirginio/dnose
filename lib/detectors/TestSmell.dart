import 'package:dnose/detectors/TestClass.dart';

class TestSmell{
  String name, testName, code;
  TestClass testClass;
  int start, end;
  TestSmell(this.name,this.testName, this.testClass, {this.code = "", this.start=0, this.end=0});
}