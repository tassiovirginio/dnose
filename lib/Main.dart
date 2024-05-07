import 'dart:convert';

import 'package:logging/logging.dart';
import 'dart:io';
import "package:yaml/yaml.dart";
import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/DNose.dart';
import 'package:dnose/detectors/TestSmell.dart';

final Logger _logger = Logger('Main');

class Vars{
  static bool processando = false;
}

void main(List<String> args) {
  String path_project = "/home/tassio/Desenvolvimento/dart/conduit";
  // String path_project = "/home/tassio/Desenvolvimento/dart/dnose";
  // String path_project = "/home/tassio/Desenvolvimento/dart/flutter";
  processar(path_project);

  // if(args.length == 1){
  //   processar(args[0]);
  //   return;
  // }
}

void processar(String path_project) {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _logger.info("==============================================");
  _logger.info("========= Dart Test Smells Detector ==========");
  _logger.info("==============================================");

  DNose dnose = DNose();

  List<TestSmell> lista_total = List.empty(growable: true);

  Directory dir = Directory(path_project);
  List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();
  String project_name = path_project.split("/").last;

  String module_atual = "";

  String diretorio_atual = "";

  entries.forEach((file) {
    if (diretorio_atual.isEmpty) {
      diretorio_atual = file.parent.path;
    } else if (diretorio_atual != file.parent.path) {
      diretorio_atual = file.parent.path;
      File file2 = new File(diretorio_atual + "/pubspec.yaml");

      if (file2.existsSync()) {
        String yamlString = file2.readAsStringSync();
        Map yaml = loadYaml(yamlString);
        module_atual = yaml['name'];
      }
    }

    if (file.path.endsWith("_test.dart") == true) {
      _logger.info("Analyzing: " + file.path);
      TestClass testClass = TestClass(file.path, module_atual, project_name);
      var testSmells = dnose.scan(testClass);
      lista_total.addAll(testSmells);
    }
  });

  createCSV(lista_total);

  _logger.info(
      "Foram encontrado " + lista_total.length.toString() + " Test Smells.");
}

void createCSV(List<TestSmell> lista_total) {
  var file = File('resultado.csv');
  var sink = file.openWrite();
  sink.write("project_name;test_name;module;path;testsmell;start;end\n");
  lista_total.forEach((ts) {
    sink.write(
        "${ts.testClass?.project_name};${ts.testName};${ts.testClass?.module_atual};${ts.testClass?.path};${ts.name!};${ts.start};${ts.end}\n");
    _logger.info(
        "${ts.testClass?.project_name};${ts.testName};${ts.testClass?.module_atual};${ts.testClass?.path};${ts.name!};${ts.start};${ts.end}");
    _logger.info("Code: " + ts.code);
  });
  sink.close();
}
