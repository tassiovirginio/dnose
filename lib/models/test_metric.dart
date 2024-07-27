import 'package:dnose/models/test_class.dart';

class TestMetric {
  String name, testName, code;
  TestClass testClass;
  int start, end;
  int value;

  TestMetric({
    required this.name,
    required this.testName,
    required this.testClass,
    required this.code,
    required this.start,
    required this.end,
    required this.value,
  });
}
