import 'dart:io';

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
  final DNose dnose = DNose();

  // Set<String> setTest = <String>{};

  print('Current directory: $path');

  if (await GitDir.isGitDir(path)) {

    final db = initializeDatabase();

    final gitDir = await GitDir.fromExisting(path);

    // Vai para a branch master ou main
    try {
      await gitDir.runCommand(['checkout', "master"]);
    } catch (e) {
      print("Erro ao tentar mudar para a branch master");
    }
    try {
      await gitDir.runCommand(['checkout', "main"]);
    } catch (e) {
      print("Erro ao tentar mudar para a branch main");
    }

    //Carrega a lista de commits
    final lista = await GitUtil.getListCommits(path);

    for (final c in lista.values) {
      // pega o código HASH do commit
      final String commit =
          c.content.split(" ")[1].replaceAll("tree", "").trim();

      // pega a lista de arquivos que foram modificados no commit
      final List<String> retorno_ =
          await GitUtil.getFileChangeCommit(path, commit);

      //cria uma lista vazia
      final List<String> listaArquivos = [];

      // adiciona na lista de arquivos apenas os arquivos que são de teste
      for (final String file in retorno_) {
        if (file.contains('_test.dart')) {
          listaArquivos.add(file);
        }
      }

      //verifica se a lista esta vazia
      if (listaArquivos.isNotEmpty) {

        // muda para o commit - checkout commit
        await gitDir.runCommand(['checkout', commit]);

        // inicia a navegação de arquivo por arquivo
        for (final String file in listaArquivos) {
          try {
            // cria uma testclass
            TestClass testClass = TestClass(
                commit: commit,
                path: "$path/$file",
                moduleAtual: "",
                projectName: path.split("/").last);

            // cria um MAP com a lista de testsmells encontrados e as métricas
            final (List<TestSmell>, List<TestMetric>) mapa =
                dnose.scan(testClass);

            // Map utilizado para controlar as ocorrencias 'duplicadas'
            final mapUtil = MapUtil();

            //pega a lista de testsmells
            List<TestSmell> testSmells = mapa.$1;

            // intera sobre a lista de testsmells
            for (var ts in testSmells) {
              String codeMD5 = Util.MD5(ts.code);
              int qtd = mapUtil.add(ts.codeTestMD5!, codeMD5);


              //dados que podem ser utilizados para gerar o identificados único
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


              // gera o identificador UNICO para o testsmell
              String md5TestSmell = Util.MD5(
                  ts.codeTestMD5! +
                  ts.codeMD5 + ts.collumnStart.toString()
              );

              print("TestSmell.MD5TS: $md5TestSmell");

              String msgFilter = c.message.replaceAll(";", "-").replaceAll("\n", " ").replaceAll("\r", " ");

              String commitUserName = c.author.split("<").first;
              String commitDate = c.author.split(">").last;
              String commitDateFormatted = Util.date(commitDate);

              // verifica se o testsmell já foi cadastrado no banco de dados
              final exists = checkIfMd5TestSmellExists(db, md5TestSmell);

              // se existir, atualiza a data de UPDATE, se NÃO -> insere no banco de dados
              if (exists) {
                print('Registro com md5TestSmell já existe.');

                //atualiza o testsmell
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
            }

            print(
                "$commit -> $file -> Quantidade de Test Smells: ${mapa.$1.length}");
          } catch (e) {
            print("Erro ao analisar arquivo: $file");
          }

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

  /// Retorna a lista de commits dos mais antigos para os mais novos
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
  db.execute('''
    UPDATE TestSmells
    SET date_update = ?
    WHERE md5TestSmell = ?
  ''', [dateUpdate, md5TestSmell]);

  print('Data atualizada com sucesso para o md5TestSmell $md5TestSmell.');
}