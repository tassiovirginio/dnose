import 'package:git/git.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  print('Current directory: ${p.current}');

  if (await GitDir.isGitDir(p.current)) {
    final gitDir = await GitDir.fromExisting(p.current);
    final commitCount = await gitDir.commitCount();
    print('Git commit count: $commitCount');

    final latestCommit = await gitDir.currentBranch();
    print('Latest commit: $latestCommit');

    final currentBranch = await gitDir.currentBranch();
    final name = currentBranch.branchName;
    print('BranchName: $name');

    final lista = await gitDir.branches();
    lista.forEach((element) {
      print(element.branchName);
    });

    final retorno = await gitDir.runCommand(['status']);
    print(retorno.stdout);
  } else {
    print('Not a Git directory');
  }
}

class GitUtil{

  static Future<String> getCurrentBranch(String path) async{
    final gitDir = await GitDir.fromExisting(path);
    final currentBranch = await gitDir.currentBranch();
    final name = currentBranch.branchName;
    return name;
  }

  static Future<int> getSizeCommits(String path) async{
    final gitDir = await GitDir.fromExisting(path);
    final commitCount = await gitDir.commitCount();
    return commitCount;
  }

  static Future<Map<String, Commit>> getListCommits(String path) async{
    final GitDir gitDir = await GitDir.fromExisting(path);
    final Map<String, Commit> mapa = await gitDir.commits();
    return mapa;
  }

}

