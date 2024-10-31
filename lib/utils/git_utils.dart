import 'package:git/git.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  var path = "/home/tassio/Desenvolvimento/repo.git/dnose";

  print('Current directory: ${path}');

  if (await GitDir.isGitDir(path)) {
    final gitDir = await GitDir.fromExisting(path);
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

      if(listaArquivos.length > 0){
        print("Indo para commit $commit e analisando arquivos: $listaArquivos");
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
