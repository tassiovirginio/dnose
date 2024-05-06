// import 'dart:ffi';
// import 'dart:io';

import 'dart:io';
import "package:yaml/yaml.dart";
import 'package:dnose/detectors/TestClass.dart';
// import 'package:teste01/detectors/TestSmell.dart';
import 'package:dnose/DNose.dart';
import 'package:dnose/detectors/TestSmell.dart';

void main() {
  print("==============================================");
  print("========= Dart Test Smells Detector ==========");
  print("==============================================\n");

  String path_project = "/home/tassio/Desenvolvimento/dart/conduit";
  // String path_project = "/home/tassio/Desenvolvimento/dart/dnose/test/";
  // String path_project = "/home/tassio/Desenvolvimento/dart/flutter";

  Directory dir = Directory(path_project);

  List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();

  DNose dnose = DNose();

  List<TestSmell> lista_total = List.empty(growable: true);

  // String path_project_pubspec = path_project + "/pubspec.yaml";
  // File file = new File(path_project_pubspec);
  // String yamlString = file.readAsStringSync();
  // Map yaml = loadYaml(yamlString);
  // print(yaml['name']);


  String projeto_atual = "";

  entries.forEach((file) {
    if(file.path.endsWith("_test.dart") == true || file.path.endsWith("/pubspec.yaml") == true) {
      if(file.path.endsWith("/pubspec.yaml") == true){
        File file2 = new File(file.path);
        String yamlString = file2.readAsStringSync();
        Map yaml = loadYaml(yamlString);
        projeto_atual = yaml['name'];
      }else{
        print("Analisando: " + file.path + "\n");
        TestClass testClass = TestClass(file.path,projeto_atual);
        var testSmells = dnose.scan(testClass);
        lista_total.addAll(testSmells);
      }
    }
  });

  var file = File('resultado.csv');
  var sink = file.openWrite();

  lista_total.forEach((ts) {
    sink.write("${ts.testClass?.project},${ts.testClass?.path},${ts.name!}\n");
    print("${ts.testClass?.path},${ts.name!},${ts.testClass?.project}\n");
    print("Código: " + ts.code);
    print("\n\n----------------------------------------------");
  });

  // Close the IOSink to free system resources.
  sink.close();

  print("\n\n----------------------------------------------");
  print("Foram encontrado " + lista_total.length.toString() +
      " Test Smells.\n");




}
