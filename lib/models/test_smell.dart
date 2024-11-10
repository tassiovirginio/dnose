import 'package:dnose/models/test_class.dart';

class TestSmell {
  String name, testName, code;
  String? codeTest;
  String? codeTestMD5;
  TestClass testClass;
  int start, end, startTest, endTest;

  TestSmell({
    required this.name,
    required this.testName,
    required this.testClass,
    required this.code,
    required this.start,
    required this.end,
    required this.codeTest,
    required this.codeTestMD5,
    required this.startTest,
    required this.endTest,
  });

}
