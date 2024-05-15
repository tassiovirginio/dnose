import 'package:dnose/models/test_class.dart';

class TestSmell {
  String name, testName, code;
  TestClass testClass;
  int start, end;

  TestSmell(
      {required this.name,
      required this.testName,
      required this.testClass,
      required this.code,
      required this.start,
      required this.end});
}
