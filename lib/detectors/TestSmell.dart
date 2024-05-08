import 'package:dnose/detectors/TestClass.dart';

class TestSmell{
  String? name, testName;
  TestClass? testClass;
  String code = "";
  int? start, end;
  TestSmell(this.name,this.testName, this.testClass, {this.code = "", this.start, this.end});
}