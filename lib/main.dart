import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart' show loadYaml;
import 'package:dnose/models/test_class.dart';
import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:crypto/crypto.dart' show md5;

final Logger _logger = Logger('Main');

void main(List<String> args) {
  var pathProject = [
    "/home/tassio/Desenvolvimento/dart/flutter",
    "/home/tassio/Desenvolvimento/repo.git/dnose",
    "/home/tassio/Desenvolvimento/dart/dnose",
    "/home/tassio/Desenvolvimento/dart/conduit"
  ];
  processar(pathProject[0]);

  // if(args.length == 1){
  //   processar(args[0]);
  //   return;
  // }
}

void processar(String pathProject) {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  _logger.info("==============================================");
  _logger.info("========= Dart Test Smells Detector ==========");
  _logger.info("==============================================");

  DNose dnose = DNose();

  List<TestSmell> listaTotal = List.empty(growable: true);

  Directory dir = Directory(pathProject);

  List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();

  String projectName = pathProject.split("/").last;

  String moduleAtual = "";

  String diretorioAtual = "";

  entries.forEach((file) {
    if (diretorioAtual.isEmpty) {
      diretorioAtual = file.parent.path;
    } else if (diretorioAtual != file.parent.path) {
      diretorioAtual = file.parent.path;
      File file2 = File("$diretorioAtual/pubspec.yaml");

      if (file2.existsSync()) {
        String yamlString = file2.readAsStringSync();
        Map yaml = loadYaml(yamlString);
        moduleAtual = yaml['name'];
      }
    }

    if (file.path.endsWith("_test.dart") == true) {
      _logger.info("Analyzing: ${file.path}");
      TestClass testClass = TestClass(file.path, moduleAtual, projectName);
      var testSmells = dnose.scan(testClass);
      listaTotal.addAll(testSmells);
    }
  });

  createCSV(listaTotal);

  _logger.info(
      "Foram encontrado ${listaTotal.length} Test Smells.");
}

var somatorio = Map<String, int>();

void createCSV(List<TestSmell> listaTotal) {
  var file = File('resultado.csv');

  if(file.existsSync()){
    file.deleteSync();
  }

  file.createSync();

  var sink = file.openWrite();
  sink.write("project_name;test_name;module;path;testsmell;start;end\n");
  listaTotal.forEach((ts) {
    sink.write(
        "${ts.testClass.projectName};${ts.testName};${ts.testClass.moduleAtual};${ts.testClass.path};${ts.name};${ts.start};${ts.end}\n");
    _logger.info(
        "${ts.testClass.projectName};${ts.testName};${ts.testClass.moduleAtual};${ts.testClass.path};${ts.name};${ts.start};${ts.end}");
    _logger.info("Code: ${ts.code}");

    if (somatorio[ts.name] == null) {
      somatorio[ts.name] = 1;
    } else {
      somatorio[ts.name] = somatorio[ts.name]! + 1;
    }
  });
  sink.close();

  var file2 = File('resultado2.csv');

  if(file2.existsSync()){
    file2.deleteSync();
  }

  file2.createSync();

  var sink2 = file2.openWrite();
  sink2.write("test_smell;qtd\n");
  somatorio.forEach((key, value) {
    sink2.write("$key;$value\n");
    _logger.info("$key;$value");
  });
  sink2.close();
}

String generateMd5(String input) => md5.convert(utf8.encode(input)).toString();
