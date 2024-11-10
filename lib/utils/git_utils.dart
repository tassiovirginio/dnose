import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  var path = "/home/tassio/Desenvolvimento/repo.git/flutter";
  mining(path);
}

void mining(String path) async {
  DNose dnose = DNose();

  Set<String> setTest = <String>{};

  print('Current directory: ${path}');

  if (await GitDir.isGitDir(path)) {
    //criando o arquivo csv
    var file = File('resultado_mining.csv');
    if (file.existsSync()) file.deleteSync();
    file.createSync();
    var sink = file.openWrite();
    sink.write(
        "projectName;testName;path;testsmell;commit;author;message;md5TestSmell\n");

    final gitDir = await GitDir.fromExisting(path);
    final checkoutHEAD = await gitDir.runCommand(['checkout', "HEAD"]);
    // final commitCount = await gitDir.commitCount();
    // print('Git commit count: $commitCount');

    // final latestCommit = await gitDir.currentBranch();
    // print('Latest commit: $latestCommit');

    // final currentBranch = await gitDir.currentBranch();
    // final name = currentBranch.branchName;
    // print('BranchName: $name');

    // final lista = await gitDir.branches();
    // lista.forEach((element) {
    //   print(element.branchName);
    // });

    // final retorno = await gitDir.runCommand(['status']);
    // print(retorno.stdout);
    final lista = await GitUtil.getListCommits(path);

    for (final c in lista.values) {
      final String commit =
          c.content.split(" ")[1].replaceAll("tree", "").trim();
      // print("#######################################");
      // print("${c.author}, ${c.message} , ${commit}");

      final List<String> retorno_ =
          await GitUtil.getFileChangeCommit(path, commit);

      final List<String> listaArquivos = [];

      for (final String file in retorno_) {
        if (file.contains('_test.dart')) {
          listaArquivos.add(file);
        }
      }

      if (listaArquivos.isNotEmpty) {
        // print("Indo para commit $commit e analisando arquivos: $listaArquivos");

        final checkoutCommit = await gitDir.runCommand(['checkout', commit]);

        for (final String file in listaArquivos) {
          // print("Analisando arquivo: $file");
          try {
            TestClass testClass = TestClass(
                commit: commit,
                path: "$path/$file",
                moduleAtual: "",
                projectName: path.split("/").last);
            final (List<TestSmell>, List<TestMetric>) mapa =
                dnose.scan(testClass);

            final mapUtil = MapUtil();

            mapa.$1.forEach((ts) {
              String codeMD5 = Util.MD5(ts.code);
              int qtd = mapUtil.add(ts.codeTestMD5!, codeMD5);

              print(
                  "#####################################################################");
              print("TestSmell: ${ts.name}");
              print("TestSmell.codeTest: ${ts.codeTest}");
              print("TestSmell.codeTestMD5: ${ts.codeTestMD5}");
              print("TestSmell.code: ${ts.code}");
              print("TestSmell.codeMD5: $codeMD5");
              print("TestSmell.localStartLine: ${ts.localStartLine()}");
              print("TestSmell.localEndLine: ${ts.localEndLine()}");
              print("TestSmell.offset: ${ts.offset}");
              print("TestSmell.endOffset: ${ts.endOffset}");
              int indexOf = ts.codeTest!.indexOf(ts.code);
              int lastIndexOf = ts.codeTest!.lastIndexOf(ts.code);
              print("TestSmell.indexOf: $indexOf");
              print("TestSmell.lastIndexOf: $lastIndexOf");
              print("TestSmell.collumnStart: ${ts.collumnStart}");
              print("TestSmell.collumnEnd: ${ts.collumnEnd}");
              print("QTD: $qtd");
              String md5TestSmell = Util.MD5(ts.codeTestMD5! +
                  ts.code +
                  indexOf.toString() +
                  lastIndexOf.toString() +
                  qtd.toString());
              print("TestSmell.MD5TS: $md5TestSmell");

              if (setTest.contains(md5TestSmell)) {
                print("TestSmell já analisado");
              } else {
                setTest.add(md5TestSmell);
                print("TestSmell não analisado");
              }


              String msgFilter = c.message.replaceAll(";", "-").replaceAll("\n", " ").replaceAll("\r", " ");

              sink.write(
                  "${testClass.projectName};"
                      "${ts.testName};"
                      "$path;"
                      "${ts.name};"
                      "$commit;"
                      "${c.author};"
                      "$msgFilter;"
                      "$md5TestSmell"
                      "\n");

              // Verificar se já existe o TestSmell no banco de dados,
              // se existir, atualizar a data de UPDATE, se NÃO -> inserir no banco de dados.
              //INSERIR NO BANCO DE DADOS AQUI


            });


            print(
                "$commit -> $file -> Quantidade de Test Smells: ${mapa.$1.length}");
          } catch (e) {
            print("Erro ao analisar arquivo: $file");
          }

          // for(final TestSmell ts in mapa.$1){
          //   print("TestSmell: ${ts.name}");
          // }
        }
      }

      // print("========================================");
    }

    sink.close();
  } else {
    print('Not a Git directory');
  }
}

class GitUtil {
  static Future<String> getCurrentBranch(String path) async {
    final gitDir = await GitDir.fromExisting(path);
    final currentBranch = await gitDir.currentBranch();
    final name = currentBranch.branchName;
    return name;
  }

  static Future<int> getSizeCommits(String path) async {
    final gitDir = await GitDir.fromExisting(path);
    final commitCount = await gitDir.commitCount();
    return commitCount;
  }

  static Future<Map<String, Commit>> getListCommits(String path) async {
    final GitDir gitDir = await GitDir.fromExisting(path);
    final Map<String, Commit> mapa = await gitDir.commits();
    return mapa;
  }

  static Future<List<String>> getFileChangeCommit(
      String path, String commit) async {
    final gitDir = await GitDir.fromExisting(path);
    final retorno = await gitDir
        .runCommand(['show', '--name-only', '--pretty=' '', commit]);
    String files = retorno.stdout.toString();
    final lista = files.split('\n');
    return lista;
  }
}

class MapUtil {
  static Map<String, int> map = <String, int>{};

  int add(md5Code, md5CodeTest) {
    String key = md5Code + md5CodeTest;

    if (map.containsKey(key)) {
      map[key] = map[key]! + 1;
    } else {
      map[key] = 1;
    }

    return map[key]!;
  }
}

void openCSV() {
  var file = File('resultado_mining.csv');
  if (file.existsSync()) file.deleteSync();
  file.createSync();
  var sink = file.openWrite();
  sink.write("project_name;test_name;module;path;testsmell;start;end;commit\n");

  sink.close();
}
