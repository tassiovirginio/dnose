import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show md5;
import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:statistics/statistics.dart';
import 'package:yaml/yaml.dart' show loadYaml;
import 'package:git/git.dart';

final Logger _logger = Logger('Main');

void main(List<String> args) {
  // if(args.length == 1){
  //   processar(args[0]);
  //   return;
  // }
//
//   processar("/home/tassio/dnose_projects/devtools");
  processar("/home/tassio/Desenvolvimento/dart/dnose");

}

Future<String> processar(String pathProject) async {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  // Logger.root.onRecord.listen((record) {
  //   print('${record.level.name}: ${record.time}: ${record.message}');
  // });

  _logger.info("==============================================");
  _logger.info("========= Dart Test Smells Detector ==========");
  _logger.info("==============================================");

  String commitAtual = await getCommit(pathProject);

  DNose dnose = DNose();

  List<TestSmell> listaTotal = List.empty(growable: true);

  Directory dir = Directory(pathProject);

  List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();

  String projectName = pathProject.split("/").last;

  String moduleAtual = "";

  String diretorioAtual = "";

  for (var file in entries) {
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
      try {
        TestClass testClass = TestClass(
          commit: commitAtual,
            path: file.path,
            moduleAtual: moduleAtual,
            projectName: projectName);
        var testSmells = dnose.scan(testClass);
        listaTotal.addAll(testSmells);
      } catch (e) {
        print(e);
      }
    }
  }

  createCSV(listaTotal).then((value) {
    _logger.info("CSV criado com sucesso.");
    createSqlite().then((value) => _logger.info("SQLite criado com sucesso."));
  });

  _logger.info("Foram encontrado ${listaTotal.length} Test Smells.");

  return "OK";
}

Future<bool> createCSV(List<TestSmell> listaTotal) async {
  var somatorio = <String, int>{};

  var file = File('resultado.csv');
  if (file.existsSync()) file.deleteSync();
  file.createSync();

  var sink = file.openWrite();
  sink.write("project_name;test_name;module;path;testsmell;start;end;commit\n");
  for (var ts in listaTotal) {
    sink.write(
        "${ts.testClass.projectName};${ts.testName.replaceAll(";", ",")};${ts.testClass.moduleAtual};${ts.testClass.path};${ts.name};${ts.start};${ts.end};${ts.testClass.commit}\n");
    _logger.info(
        "${ts.testClass.projectName};${ts.testName.replaceAll(";", ",")};${ts.testClass.moduleAtual};${ts.testClass.path};${ts.name};${ts.start};${ts.end};${ts.testClass.commit}");
    _logger.info("Code: ${ts.code}");

    if (somatorio[ts.name] == null) {
      somatorio[ts.name] = 1;
    } else {
      somatorio[ts.name] = somatorio[ts.name]! + 1;
    }
  }
  sink.close();

  var file2 = File('resultado2.csv');
  if (file2.existsSync()) file2.deleteSync();
  file2.createSync();

  var sink2 = file2.openWrite();
  sink2.write("test_smell;qtd\n");
  somatorio.forEach((key, value) {
    sink2.write("$key;$value\n");
    _logger.info("$key;$value");
  });
  sink2.close();

  return true;
}

Future<bool> createSqlite() async {
  var file2 = File('resultado.sqlite');
  if (file2.existsSync()) file2.deleteSync();
  var shell = Shell();
  String dbPath = 'resultado.sqlite';
  String csvFilePath = 'resultado.csv';
  String command =
      'sqlite3 $dbPath ".mode csv" ".separator ;" ".import $csvFilePath dataset"';
  shell.run(command);
  return true;
}

List<String> getQtdTestSmellsByType() {
  final db = sqlite3.open('resultado.sqlite');
  final ResultSet resultSet = db.select(
      'select testsmell, count(testsmell) as qtd from dataset group by testsmell;');
  return resultSet.toList().map((e) => e.toString()).toList();
}

String getStatists() {
  var file = File('resultado.sqlite');
  if (!file.existsSync()) return "";

  final db = sqlite3.open('resultado.sqlite');
  final ResultSet resultSet = db.select(
      'select path, testsmell, count(testsmell) as qtd from dataset group by testsmell, path;');
  var lista = resultSet.toList();

  var mapa = <String, List<int>>{};

  for (var item in lista) {
    var testeSmell = item["testsmell"];
    if (!mapa.containsValue(testeSmell)) {
      mapa[testeSmell] = List<int>.empty(growable: true);
    }
  }

  for (var item in lista) {
    var testeSmell = item["testsmell"];
    var listaValores = mapa[testeSmell];
    listaValores!.add(item["qtd"]);
  }

  String retorno = "";

  retorno +=
      "Test Smell;Media;Standard Deviation;Median;Square Mean;Max;Min;Sum;Center;Squares Sum\n";

  for (var key in mapa.keys) {
    var listaValores = mapa[key];

    var statistics = listaValores?.statistics;

    var media = statistics?.mean;
    var desvioPadrao = statistics?.standardDeviation;
    var mediana = statistics?.median;
    var squareMean = statistics?.squaresMean;
    var sum = statistics?.sumBigInt;
    var max = statistics?.max;
    var min = statistics?.min;
    var center = statistics?.center;
    var squaresSum = statistics?.squaresSum;

    retorno +=
        "$key;$media;$desvioPadrao;$mediana;$squareMean;$max;$min;$sum;$center;$squaresSum\n";
  }

  return retorno;
}

String generateMd5(String input) => md5.convert(utf8.encode(input)).toString();


Future<String> getCommit(String path) async {
  if (await GitDir.isGitDir(path)) {
    final gitDir = await GitDir.fromExisting(path);
    // int commit = await gitDir.commitCount();
      var branch = await gitDir.currentBranch();
    return branch.sha;
  }
  return "";
}
