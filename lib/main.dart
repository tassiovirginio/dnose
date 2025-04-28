import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show md5;
import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/blame.dart';
import 'package:dnose/utils/git_log.dart';
import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:statistics/statistics.dart';
import 'package:yaml/yaml.dart' show loadYaml;
import 'package:git/git.dart';
import 'package:sentiment_dart/sentiment_dart.dart';

// final libsqlite3 = DynamicLibrary.open('./libsqlite3.so');

// final currentPath = Directory.current.path;
final userFolder = (Platform.isMacOS || Platform.isLinux)
    ? Platform.environment['HOME']!
    : Platform.environment['UserProfile']!;
final Directory dirUser = Directory(userFolder);
final Directory dirDNose = Directory("${dirUser.path}/.dnose");
final Directory dirProjects = Directory("${dirDNose.path}/projects");
final Directory dirResults = Directory("${dirDNose.path}/results");
final String resultadoDbFile = "${dirResults.path}/resultado.sqlite";

final Logger _logger = Logger('Main');

Future<void> main2(List<String> args) async {
  // if(args.length == 1){
  //   processar(args[0]);
  //   return;
  // }
//
  // processar(
      // "/home/tassio/dnose_projects/chicago/test/widget_surveyor_test.dart");
//   processar("/home/tassio/Desenvolvimento/dart/dnose");

  // cloandoProjetos();

  // cloandoProjetos2();

  // verificandoProjetosComAPasta();
}

void verificandoProjetosComAPasta() {
  var file =
      File("/home/tassio/Desenvolvimento/dart/dnose/dataset_dart_projects.csv");
  var lista = file.readAsLinesSync();
  var localPath = "/home/tassio/dnose_projects/";

  var lista2 = lista
      .map((e) => e.split(",")[2].toString().split("/").last.toString())
      .toList();

  var listaDir = Directory(localPath).listSync();
  for (var dir in listaDir) {
    var name = dir.path.split("/").last;

    if (lista2.contains(name)) {
      // print("Tem -> ${name}");
    } else {
      print(name);
    }
  }
}

void cloandoProjetos() async {
  var file =
      File("/home/tassio/Desenvolvimento/dart/dnose/dataset_dart_projects.csv");
  var lista = file.readAsLinesSync();

  var localPath = "/home/tassio/dnose_projects/";

  // int cont = 1;

  var set = <String>{};

  for (var linha in lista) {
    var name = linha.split(",")[2].split("/").last;
    var size = linha.split("/").length;
    var url = linha.split(",")[2];

    if (size == 5) {
      if (!set.contains(url)) {
        set.add(url);
        if (Directory(localPath + name).existsSync()) {
          var listaArquivos = getFilesFromDirRecursive(localPath + name);
          int contDart = 0;
          int contTestDart = 0;
          for (FileSystemEntity file in listaArquivos) {
            if (file.path.contains(".dart")) {
              contDart = contDart + 1;
            }
            if (file.path.contains("_test.dart")) {
              contTestDart = contTestDart + 1;
            }
          }
          print(
              "$name,$contDart,$contTestDart,$url,$getURLBaseGithubProject(url)");
        } else {
          // print("${cont++},${name},${size},${url}");
          // await git.gitClone(repo: url, directory: localPath + name);
        }
      }
    } else {
      // print("${name}, ${size}, ${url}, ${getURLBaseGithubProject(url)}");
    }
  }
}

void cloandoProjetos2() async {
  var localPath = "/home/tassio/dnose_projects/";

  var listaPastas = Directory(localPath).listSync();

  for (var pasta in listaPastas) {
    String nome = pasta.path.split("/").last;

    var listaArquivos = getFilesFromDirRecursive(pasta.path);
    int contDart = 0;
    int contTestDart = 0;
    for (FileSystemEntity file in listaArquivos) {
      if (file.path.contains(".dart")) {
        contDart = contDart + 1;
      }
      if (file.path.contains("_test.dart")) {
        contTestDart = contTestDart + 1;
      }
    }
    // if(contTestDart > 0)
    print("$nome,$contDart,$contTestDart");
  }
}

String getURLBaseGithubProject(String url) {
  var urlList = url.split("/");
  String urlFinal = "";

  if (urlList.length > 4) {
    var urlFinal = urlList
        .sublist(0, 5)
        .map(
          (e) => "$e/",
        )
        .toString();
    urlFinal = urlFinal
        .toString()
        .replaceAll(",", "")
        .replaceAll(" ", "")
        .replaceAll("(", "")
        .replaceAll(")", "");
  }

  return urlFinal;
}

List<FileSystemEntity> getFilesFromDirRecursive(String path) {
  List<FileSystemEntity> result = [];
  Directory dir = Directory(path);
  List<FileSystemEntity> entities = dir.listSync().toList();
  for (var entity in entities) {
    if (entity is File) {
      result.add(entity);
    } else if (entity is Directory) {
      result.addAll(getFilesFromDirRecursive(entity.path));
    }
  }
  return result;
}

Future<String> processar(String listPathProjects) async {
  List<TestSmell> listaTotal = List.empty(growable: true);
  List<TestMetric> listaTotalMetrics = List.empty(growable: true);
  List<String> listaArquivosTestes = List.empty(growable: true);

  var lista = listPathProjects.split(";");

  var file = File('${dirResults.path}/commits.csv');
  if (file.existsSync()) file.deleteSync();

  for (final project in lista) {
    if (project.trim().isNotEmpty) {
      var (listaTotal2, listaTotalMetrics2,listaArquivosTestes2) = await _processar(project);
      listaTotal.addAll(listaTotal2);
      listaTotalMetrics.addAll(listaTotalMetrics2);
      listaArquivosTestes.addAll(listaArquivosTestes2);
    }
  }

  await createCSV(listaTotal);

  await createMatricsCSV(listaTotalMetrics);

  await createListFilesTestsCSV(listaArquivosTestes);

  await createSqlite();

  _logger.info("Foram encontrado ${listaTotal.length} Test Smells.");

  return "OK";
}

Future<String> processarAll() async {
  List<TestSmell> listaTotal = List.empty(growable: true);
  List<TestMetric> listaTotalMetrics = List.empty(growable: true);
  List<String> listaArquivosTestes = List.empty(growable: true);

  final directories =
  dirProjects.listSync().whereType<Directory>();

  var file = File('${dirResults.path}/commits.csv');
  if (file.existsSync()) file.deleteSync();

  for (final folder in directories) {
    var (listaTotal2, listaTotalMetrics2, listaArquivosTestes2) = await _processar(folder.path);
    listaTotal.addAll(listaTotal2);
    listaTotalMetrics.addAll(listaTotalMetrics2);
    listaArquivosTestes.addAll(listaArquivosTestes2);
  }

  await createCSV(listaTotal);
  await createMatricsCSV(listaTotalMetrics);
  await createListFilesTestsCSV(listaArquivosTestes);
  await createSqlite();

  _logger.info("Foram encontrado ${listaTotal.length} Test Smells.");

  return "OK";
}

List<FileSystemEntity> listarSemPastasOcultas(String pathProject) {
  final dir = Directory(pathProject);

  return dir
      .listSync(recursive: true)
      .where((entry) {
    // Ignora se tiver diretório oculto no caminho
    // final parts = entry.path.split(Platform.pathSeparator);
    // final temDiretorioOculto = parts.any((part) => part.startsWith('.'));

    // Só queremos arquivos .dart
    final ehArquivoDart = entry is File && entry.path.endsWith('.dart');

    return ehArquivoDart;
  })
      .toList();
}

Future<(List<TestSmell>, List<TestMetric>, List<String>)> _processar(
    String pathProject) async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO

  _logger.info("==============================================");
  _logger.info("========= Dart Test Smells Detector ==========");
  _logger.info("==============================================");

  String commitAtual = await getCommit(pathProject);
  await generateGitLogCsv(pathProject, dirResults.path);

  DNose dnose = DNose();

  List<TestSmell> listaTotal = List.empty(growable: true);
  List<TestMetric> listaTotalMetrics = List.empty(growable: true);
  List<String> listaArquivosTestes = List.empty(growable: true);

  // Directory dir = Directory(pathProject);
  // List<FileSystemEntity> entries = dir.listSync(recursive: true).toList();

  final entries = listarSemPastasOcultas(pathProject);

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
        String yamlString = "";
        try {
          yamlString = file2.readAsStringSync();
          Map yaml = loadYaml(yamlString);
          moduleAtual = yaml['name'];
        } catch (e) {
          moduleAtual = "";
        }
      }
    }

    if (file.path.endsWith("_test.dart") == true) {
      listaArquivosTestes.add(file.path);
      _logger.info("Analyzing: ${file.path}");
      //contador de procentagem para a tela
      DNose.contProcessProject++;

      try {
        TestClass testClass = TestClass(
            commit: commitAtual,
            path: file.path,
            moduleAtual: moduleAtual,
            projectName: projectName);
        var (testSmells, testMetrics) = dnose.scan(testClass);

        //Blame
        Map<String,BlameLine> fileBlame = blameFile(file.path, pathProject);
        for(var ts in testSmells){
          BlameLine? blameLine = fileBlame[ts.start.toString()];
          ts.lineNumber = blameLine!.lineNumber;
          ts.commitAuthor = blameLine.commit;
          ts.author = blameLine.author;
          ts.dateStr = blameLine.dateStr;
          ts.timeStr = blameLine.timeStr;
          ts.summary = blameLine.summary;
          //sentiment
          SentimentResult sentimentResult = Sentiment.analysis(blameLine.summary.toString(),emoji: true);
          ts.score = sentimentResult.score;
          ts.comparative = sentimentResult.comparative;
          ts.words = sentimentResult.words;
        }

        listaTotal.addAll(testSmells);
        listaTotalMetrics.addAll(testMetrics);
      } catch (e) {
        print(e);
      }
    }
  }

  return (listaTotal, listaTotalMetrics, listaArquivosTestes);
}

int qtd(String texto, String palavra) {
  return RegExp(palavra).allMatches(texto).length;
}

Future<bool> createCSV(List<TestSmell> listaTotal) async {
  var somatorio = <String, int>{};

  var file = File('${dirResults.path}/resultado.csv');
  if (file.existsSync()) file.deleteSync();
  file.createSync();
  var sink = file.openWrite();
  sink.write("project_name;test_name;module;path;testsmell;start;end;commit;");
  sink.write("lineNumber;commitAuthor;author;dateStr;timeStr;summary;");
  sink.write("score;comparative;words;\n");

  var file4 = File('${dirResults.path}/metrics2.csv');
  if (file4.existsSync()) file4.deleteSync();
  file4.createSync();
  var sink4 = file4.openWrite();
  sink4.write(
      "project_name;test_name;module;path;testsmell;start;end;commit;qtdLine;qtdLineTeste;"
      "for;while;if;sleep;expect;catch;throw;try;number;print;file;"
      "forT;whileT;ifT;sleepT;expectT;catchT;throwT;tryT;printT;fileT"
      "\n");

  for (TestSmell ts in listaTotal) {
    String codeLine = ts.code.trim().replaceAll(" ", "");
    var containsFor = codeLine.contains('for(') ? 1 : 0;
    var containsWhile = codeLine.contains('while(') ? 1 : 0;
    var containsIf = codeLine.contains('if(') ? 1 : 0;
    var containsSleep = codeLine.contains('sleep(') ? 1 : 0;
    var containsExpect = codeLine.contains('expect(') ? 1 : 0;
    var containsCatch = codeLine.contains('catch') ? 1 : 0;
    var containsThrow = codeLine.contains('throw') ? 1 : 0;
    var containsTry = codeLine.contains('try') ? 1 : 0;
    var containsNumber = codeLine.contains(RegExp(r'\d+')) ? 1 : 0;
    var containsPrint = codeLine.contains('print') ? 1 : 0;
    var containsFile = codeLine.contains('File') ? 1 : 0;

    String codeLineTest = ts.codeTest!;
    var containsForTeste = qtd(codeLineTest, 'for');
    var containsWhileTeste = qtd(codeLineTest, 'while');
    var containsIfTeste = qtd(codeLineTest, 'if');
    var containsSleepTeste = qtd(codeLineTest, 'sleep');
    var containsExpectTeste = qtd(codeLineTest, 'expect');
    var containsCatchTeste = qtd(codeLineTest, 'catch');
    var containsThrowTeste = qtd(codeLineTest, 'throw');
    var containsTryTeste = qtd(codeLineTest, 'try');
    var containsPrintTeste = qtd(codeLineTest, 'print');
    var containsFileTeste = qtd(codeLineTest, 'File');

    int qtdLine = ts.end - ts.start + 1;
    int qtdLineTeste = ts.endTest - ts.startTest + 1;

    sink4.write("${ts.testClass.projectName}"
        ";${ts.testName.replaceAll(";", ",").replaceAll("\n", ".")}"
        ";${ts.testClass.moduleAtual};${ts.testClass.path};${ts.name}"
        ";${ts.start};${ts.end};${ts.testClass.commit};$qtdLine;$qtdLineTeste;"
        "$containsFor;$containsWhile;$containsIf;$containsSleep;"
        "$containsExpect;$containsCatch;$containsThrow;$containsTry;$containsNumber;$containsPrint;$containsFile;"
        "$containsForTeste;$containsWhileTeste;$containsIfTeste;$containsSleepTeste;"
        "$containsExpectTeste;$containsCatchTeste;$containsThrowTeste;$containsTryTeste;$containsPrintTeste;$containsFileTeste"
        "\n");

    sink.write(
        "${ts.testClass.projectName};${ts.testName.replaceAll(";", ",").replaceAll("\n", ".")};${ts.testClass.moduleAtual};${ts.testClass.path};"
            "${ts.name};${ts.start};${ts.end};${ts.testClass.commit};");
    sink.write(
        "${ts.lineNumber};${ts.commitAuthor};${ts.author!.replaceAll(";", ",")};${ts.dateStr};"
            "${ts.timeStr};${ts.summary!.replaceAll(";", ",").replaceAll("\n", ".").replaceAll('"', "")};");
    sink.write(
        "${ts.score};${ts.comparative};${ts.words};\n");


    _logger.info(
        "${ts.testClass.projectName};${ts.testName.replaceAll(";", ",").replaceAll("\n", ".")};${ts.testClass.moduleAtual};${ts.testClass.path};${ts.name};${ts.start};${ts.end};${ts.testClass.commit}");
    _logger.info("Code: ${ts.code}");

    if (somatorio[ts.name] == null) {
      somatorio[ts.name] = 1;
    } else {
      somatorio[ts.name] = somatorio[ts.name]! + 1;
    }
  }

  var file2 = File('${dirResults.path}/resultado2.csv');
  if (file2.existsSync()) file2.deleteSync();
  file2.createSync();

  var sink2 = file2.openWrite();
  sink2.write("test_smell;qtd\n");
  somatorio.forEach((key, value) {
    sink2.write("$key;$value\n");
    _logger.info("$key;$value");
  });

  await sink.close();
  await sink2.close();
  await sink4.close();

  return true;
}

Future<bool> createListFilesTestsCSV(List<String> listFileTests) async {
  var file = File('${dirResults.path}/list_files_tests.csv');
  if (file.existsSync()) file.deleteSync();
  file.createSync();

  var sink = file.openWrite();
  sink.write(
      "pathFile\n");
  for (var m in listFileTests) {
    sink.write("$m\n");
  }
  sink.close();

  return true;
}

Future<bool> createMatricsCSV(List<TestMetric> listaTotal) async {
  var file = File('${dirResults.path}/resultado_metrics.csv');
  if (file.existsSync()) file.deleteSync();
  file.createSync();

  var sink = file.openWrite();
  sink.write(
      "project_name;test_name;module;path;metric;start;end;value;commit\n");
  for (var m in listaTotal) {
    sink.write(
        "${m.testClass.projectName};${m.testName.replaceAll(";", ",").replaceAll("\n", ".")};${m.testClass.moduleAtual};${m.testClass.path};${m.name};${m.start};${m.end};${m.value};${m.testClass.commit}\n");
    _logger.info(
        "${m.testClass.projectName};${m.testName.replaceAll(";", ",").replaceAll("\n", ".")};${m.testClass.moduleAtual};${m.testClass.path};${m.name};${m.start};${m.end};${m.value};${m.testClass.commit}");
    _logger.info("Code: ${m.code}");
  }
  sink.close();

  return true;
}

Future<bool> createSqlite() async {
  var file2 = File(resultadoDbFile);
  if (file2.existsSync()) file2.deleteSync();
  var shell = Shell();
  String dbPath = '${dirResults.path}/resultado.sqlite';
  String csvFilePath = '${dirResults.path}/resultado.csv';
  String csvMEtricsFilePath = '${dirResults.path}/resultado_metrics.csv';
  String csvFileTests = '${dirResults.path}/list_files_tests.csv';
  String csvCommits = '${dirResults.path}/commits.csv';
  String command =
      'sqlite3 $dbPath ".mode csv" ".separator ;" ".import $csvFilePath testsmells"';
  String command2 =
      'sqlite3 $dbPath ".mode csv" ".separator ;" ".import $csvMEtricsFilePath metrics"';
  String command3 =
      'sqlite3 $dbPath ".mode csv" ".separator ;" ".import $csvFileTests filestests"';
  String command4 =
      'sqlite3 $dbPath ".mode csv" ".separator ;" ".import $csvCommits commits"';
  await shell.run(command);
  await shell.run(command2);
  await shell.run(command3);
  await shell.run(command4);
  return true;
}

List<String> getQtdTestSmellsByType() {
  final db = sqlite3.open(resultadoDbFile);
  final ResultSet resultSet = db.select(
      'select testsmell, count(testsmell) as qtd from testsmells group by testsmell;');
  return resultSet.toList().map((e) => e.toString()).toList();
}

List<String> getProjects() {
  if (File(resultadoDbFile).existsSync()) {
    final db = sqlite3.open(resultadoDbFile);
    final ResultSet resultSet =
        db.select('select distinct project_name from testsmells;');
    return resultSet.toList().map((e) => e.toString()).toList();
  } else {
    return [];
  }
}

void main(){
  print(getSizeTestFiles());
}

int getSizeTestFiles(){
  if(File(resultadoDbFile).existsSync() == false) return 0;
  final db = sqlite3.open(resultadoDbFile);
  final ResultSet resultSet = db.select('SELECT COUNT(1) FROM filestests;');
  final int count = resultSet.first.values.first as int;
  db.dispose();
  return count;
}

String getStatists() {
  var file = File(resultadoDbFile);
  if (file.existsSync() == false) return "";
  final db = sqlite3.open(resultadoDbFile);
  final ResultSet resultSet = db.select(
      'select path, testsmell, count(testsmell) as qtd from testsmells group by testsmell, path;');
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

    int qtdTotalFilesTests = getSizeTestFiles();

    int qtdSemTestSmells = qtdTotalFilesTests - listaValores!.length;

    var arrayComZeros = List.filled(qtdSemTestSmells, 0);

    listaValores.addAll(arrayComZeros);

    listaValores.sort();

    var statistics = listaValores.statistics;

    var media = statistics.mean;
    var desvioPadrao = statistics.standardDeviation;
    var mediana = statistics.median;
    var squareMean = statistics.squaresMean;
    var sum = statistics.sumBigInt;
    var max = statistics.max;
    var min = statistics.min;
    var center = statistics.center;
    var squaresSum = statistics.squaresSum;

    retorno +=
        "$key;$media;$desvioPadrao;$mediana;$squareMean;$max;$min;$sum;$center;$squaresSum\n";
  }
  return retorno;
}

String generateMd5(String input) => md5.convert(utf8.encode(input)).toString();

Future<String> getCommit(String path) async {
  if (await GitDir.isGitDir(path)) {
    final gitDir = await GitDir.fromExisting(path);
    var branch = await gitDir.currentBranch();
    return branch.sha;
  }
  return "";
}
