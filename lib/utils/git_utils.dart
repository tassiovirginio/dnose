import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {

  Set<String> setTest = <String>{};

  DNose dnose = DNose();
  var path = "/home/tassio/Desenvolvimento/repo.git/flutter";


  print('Current directory: ${path}');

  if (await GitDir.isGitDir(path)) {
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


    for(final c in lista.values){
      final String commit = c.content.split(" ")[1].replaceAll("tree", "").trim();
      // print("#######################################");
      // print("${c.author}, ${c.message} , ${commit}");

      final List<String> retorno_ = await GitUtil.getFileChangeCommit(
        path, commit);

      final List<String> listaArquivos = [];

      for(final String file in retorno_){
        if(file.contains('_test.dart')){
          listaArquivos.add(file);
        }
      }

      if(listaArquivos.isNotEmpty){
        // print("Indo para commit $commit e analisando arquivos: $listaArquivos");

        final checkoutCommit = await gitDir.runCommand(['checkout', commit]);

        for(final String file in listaArquivos){
          // print("Analisando arquivo: $file");
            try{
            TestClass testClass = TestClass(commit: commit, path: "$path/$file", moduleAtual: "", projectName: "");
            final (List<TestSmell>,List<TestMetric>) mapa = dnose.scan(testClass);

            final mapUtil = MapUtil();

            mapa.$1.forEach((ts) {

              String codeMD5 = Util.MD5(ts.code);
              int qtd = mapUtil.add(ts.codeTestMD5!,codeMD5);

              print("#####################################################################");
              print("TestSmell: ${ts.name}");
              print("TestSmell.codeTest: ${ts.codeTest}");
              print("TestSmell.codeTestMD5: ${ts.codeTestMD5}");
              print("TestSmell.code: ${ts.code}");
              print("TestSmell.codeMD5: $codeMD5");
              int indexOf = ts.codeTest!.indexOf(ts.code);
              int lastIndexOf = ts.codeTest!.lastIndexOf(ts.code);
              print("TestSmell.indexOf: $indexOf");
              print("TestSmell.lastIndexOf: $lastIndexOf");
              print("QTD: $qtd");
              String md5TestSmell = Util.MD5(ts.codeTestMD5! + ts.code + indexOf.toString() + lastIndexOf.toString() + qtd.toString());
              print("TestSmell.MD5TS: $md5TestSmell");

              if(setTest.contains(md5TestSmell)) {
                print("TestSmell já analisado");
              }else{
                setTest.add(md5TestSmell);
                print("TestSmell não analisado");
              }


            });
            print("$commit -> $file -> Quantidade de Test Smells: ${mapa.$1.length}");
          }catch (e){
            print("Erro ao analisar arquivo: $file");
          }
           
          // for(final TestSmell ts in mapa.$1){
          //   print("TestSmell: ${ts.name}");
          // }
        }
      }
      
      
      // print("========================================");
    }


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

class MapUtil{
  static Map<String, int> map = <String, int>{};

  int add(md5Code, md5CodeTest){

    String key = md5Code + md5CodeTest;

    if(map.containsKey(key)) {
      map[key] = map[key]! + 1;
    }else{
      map[key] = 1;
    }

    return map[key]!;
  }
}
