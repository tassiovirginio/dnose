// import 'dart:ffi';
// import 'dart:io';

import 'package:teste01/TestClass.dart';
// import 'package:teste01/detectors/TestSmell.dart';
import 'package:teste01/DNose.dart';

void main() {
  print("==============================================");
  print("========= DART Test Smells Detector ==========");
  print("==============================================\n");

  DNose dnose = DNose();

  TestClass testClass = TestClass(
      '/home/tassio/Desenvolvimento/Dart/teste01/test/teste01_test.dart');

  var testSmells = dnose.scan(testClass);

  print("Foram encontrado " + testSmells.length.toString() + " Test Smells.\n");

  testSmells.forEach((element) {
    print("Test Smell: " + element.name!);
    print("Código: " + element.code);
    print("----------------------------------------------");
  });
}
