import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';
import 'package:git/git.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  var path = "/home/tassio/Desenvolvimento/repo.git/flutter";
  mining(path);
}

void mining(String path) async {
  DNose dnose = DNose();

  Set<String> setTest = <String>{};

  print('Current directory: ${path}');

  if (await GitDir.isGitDir(path)) {

    final db = initializeDatabase();


    //criando o arquivo csv
    // var file = File('resultado_mining.csv');
    // if (file.existsSync()) file.deleteSync();
    // file.createSync();
    // var sink = file.openWrite();
    // sink.write(
    //     "projectName;testName;path;testsmell;commit;author;date;message;md5TestSmell\n");

    final gitDir = await GitDir.fromExisting(path);
    final checkoutHEAD = await gitDir.runCommand(['checkout', "master"]);
    final checkoutHEAD2 = await gitDir.runCommand(['checkout', "main"]);
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

              String commitUserName = c.author.split("<").first;
              String commitDate = c.author.split(">").last;
              String commitDateFormatted = Util.date(commitDate);

              // sink.write(
              //     "${testClass.projectName};"
              //         "${ts.testName};"
              //         "$path/$file;"
              //         "${ts.name};"
              //         "$commit;"
              //         "$commitUserName;"
              //         "$commitDateFormatted;"
              //         "$msgFilter;"
              //         "$md5TestSmell"
              //         "\n");



              // Exemplo de uso do método de verificação
              final exists = checkIfMd5TestSmellExists(db, md5TestSmell);
              if (exists) {
                print('Registro com md5TestSmell já existe.');
                updateDate(db, md5TestSmell, commitDateFormatted);
              } else {
                print('Registro com md5TestSmell não existe.');
                // Insere dados na tabela TestSmells
                insertTestSmell(
                    db,
                    projectName: testClass.projectName,
                    testName: ts.testName,
                    path: '$path/$file',
                    testsmell: ts.name,
                    commitHash: commit,
                    author: commitUserName,
                    date: commitDateFormatted,
                    message: msgFilter,
                    md5TestSmell: md5TestSmell
                );
              }

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

    // sink.close();

    db.dispose();
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
    final reversedMap = Map.fromEntries(mapa.entries.toList().reversed);
    return reversedMap;
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


// Inicializa o banco de dados e cria a tabela se necessário
Database initializeDatabase() {
  final dbPath = path.join(Directory.current.path, 'mining.db');
  final db = sqlite3.open(dbPath);

  db.execute('''
    CREATE TABLE IF NOT EXISTS TestSmells (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      projectName TEXT,
      testName TEXT,
      path TEXT,
      testsmell TEXT,
      commitHash TEXT,
      author TEXT,
      date TEXT,
      date_update TEXT,
      message TEXT,
      md5TestSmell TEXT
    )
  ''');

  return db;
}

// Método para inserir dados na tabela TestSmells
void insertTestSmell(Database db, {
  required String projectName,
  required String testName,
  required String path,
  required String testsmell,
  required String commitHash,
  required String author,
  required String date,
  required String message,
  required String md5TestSmell,
}) {
  db.execute('''
    INSERT INTO TestSmells (
      projectName, testName, path, testsmell, commitHash, author, date, message, md5TestSmell
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''', [
    projectName,
    testName,
    path,
    testsmell,
    commitHash,
    author,
    date,
    message,
    md5TestSmell
  ]);

  print('Dados inseridos com sucesso!');
}

bool checkIfMd5TestSmellExists(Database db, String md5TestSmell) {
  final result = db.select('''
    SELECT COUNT(*) AS count
    FROM TestSmells
    WHERE md5TestSmell = ?
  ''', [md5TestSmell]);

  // Retorna true se encontrar um ou mais registros, caso contrário, false
  return result.isNotEmpty && result.first['count'] > 0;
}

// Método para atualizar apenas a coluna 'date' de um registro com base no 'md5TestSmell'
void updateDate(Database db, String md5TestSmell, String dateUpdate) {
  final result = db.execute('''
    UPDATE TestSmells
    SET date_update = ?
    WHERE md5TestSmell = ?
  ''', [dateUpdate, md5TestSmell]);

  print('Data atualizada com sucesso para o md5TestSmell $md5TestSmell.');
}