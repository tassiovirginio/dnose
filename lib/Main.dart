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

  // String path_project = "/home/tassio/Desenvolvimento/dart/conduit";
  // String path_project = "/home/tassio/Desenvolvimento/dart/dnose/test/";
  String path_project = "/home/tassio/Desenvolvimento/dart/flutter";

  Directory dir = Directory(path_project);

  List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();

  DNose dnose = DNose();

  List<TestSmell> lista_total = List.empty(growable: true);

  String project_name = path_project.split("/").last;

  String module_atual = "";

  entries.forEach((file) {
    if(file.path.endsWith("_test.dart") == true || file.path.endsWith("/pubspec.yaml") == true) {
      if(file.path.endsWith("/pubspec.yaml") == true){
        File file2 = new File(file.path);
        String yamlString = file2.readAsStringSync();
        Map yaml = loadYaml(yamlString);
        module_atual = yaml['name'];
      }else{
        print("Analisando: " + file.path + "\n");
        TestClass testClass = TestClass(file.path,module_atual, project_name);
        var testSmells = dnose.scan(testClass);
        lista_total.addAll(testSmells);
      }
    }
  });

  var file = File('resultado.csv');
  var sink = file.openWrite();

  lista_total.forEach((ts) {
    sink.write("${ts.testClass?.project_name},${ts.testClass?.module_atual},${ts.testClass?.path},${ts.name!}\n");
    print("${ts.testClass?.project_name},${ts.testClass?.module_atual},${ts.testClass?.path},${ts.name!}\n");
    print("Código: " + ts.code);
    print("\n\n----------------------------------------------");
  });

  // Close the IOSink to free system resources.
  sink.close();

  print("\n\n----------------------------------------------");
  print("Foram encontrado " + lista_total.length.toString() +
      " Test Smells.\n");




}
