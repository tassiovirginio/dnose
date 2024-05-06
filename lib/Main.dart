// import 'dart:ffi';
// import 'dart:io';

import 'dart:io';

import 'package:dnose/detectors/TestClass.dart';

// import 'package:teste01/detectors/TestSmell.dart';
import 'package:dnose/DNose.dart';
import 'package:dnose/detectors/TestSmell.dart';

void main() {
  print("==============================================");
  print("========= Dart Test Smells Detector ==========");
  print("==============================================\n");

  // String path_project = "/home/tassio/Desenvolvimento/dart/conduit";
  String path_project = "/home/tassio/Desenvolvimento/dart/dnose/test/";
  // String path_project = "/home/tassio/Desenvolvimento/dart/flutter";

  Directory dir = Directory(path_project);

  List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();

  DNose dnose = DNose();

  List<TestSmell> lista_total = List.empty(growable: true);

  entries.forEach((file) {
    if(file.path.endsWith("_test.dart") == true) {
      print("Analisando: " + file.path + "\n");
      TestClass testClass = TestClass(file.path);
      var testSmells = dnose.scan(testClass);
      lista_total.addAll(testSmells);
    }
  });

  lista_total.forEach((ts) {
    print("${ts.testClass?.path},${ts.name!}\n");
    print("Código: " + ts.code);
    print("\n\n----------------------------------------------");
  });

  print("\n\n----------------------------------------------");
  print("Foram encontrado " + lista_total.length.toString() +
      " Test Smells.\n");

}
