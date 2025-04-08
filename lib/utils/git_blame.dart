import 'dart:io';
import 'package:sentiment_dart/sentiment_dart.dart';


void main() async {

  final info = await getGitBlameInfo(
    '/home/tassio/Desenvolvimento/repo.git/dnose/',
    'bin/server.dart',
    42,
  );

  if (info != null) {
    print('Commit: ${info['commit']}');
    print('Autor: ${info['author']}');
    print('Data: ${info['date']}');
    print('Mensagem: ${info['message']}');
    print('sentiment_score: ${info['sentiment_score']}');
    print('sentiment_comparative: ${info['sentiment_comparative']}');
    print('sentiment_word: ${info['sentiment_word']}');
  }
}

Future<Map<String, String>?> getGitBlameInfo(
    String repoPath,
    String filePath,
    int lineNumber,
    ) async {
  try {
    // Executa git blame na linha específica
    final result = await Process.run(
      'git',
      ['blame', '-L', '$lineNumber,$lineNumber', filePath],
      workingDirectory: repoPath,
    );

    if (result.exitCode != 0) {
      print('Erro ao executar git blame: ${result.stderr}');
      return null;
    }

    final output = result.stdout.toString().trim();

    print(output);
    final regex = RegExp(
      r'^([0-9a-f]+)\s+[^\s]+\s+\((.+?)\s+(\d{4}-\d{2}-\d{2})\s+\d{2}:\d{2}:\d{2}\s+[+-]\d{4}\s+\d+\)',
    );

    final match = regex.firstMatch(output);
    if (match == null) {
      print('Não foi possível extrair os dados do blame.');
      return null;
    }

    final commitHash = match.group(1)!;
    final author = match.group(2)!;
    final date = match.group(3)!;

    // Agora busca a mensagem do commit
    final commitResult = await Process.run(
      'git',
      ['show', '-s', '--format=%s', commitHash],
      workingDirectory: repoPath,
    );

    if (commitResult.exitCode != 0) {
      print('Erro ao obter mensagem do commit: ${commitResult.stderr}');
      return null;
    }

    final commitMessage = commitResult.stdout.toString().trim();

    SentimentResult sentimentResult = Sentiment.analysis(commitMessage, emoji: true);

    return {
      'commit': commitHash,
      'author': author,
      'date': date,
      'message': commitMessage,
      'sentiment_score' : sentimentResult.score.toString(),
      'sentiment_comparative' : sentimentResult.comparative.toString(),
      'sentiment_word' : sentimentResult.words.toString(),
    };
  } catch (e) {
    print('Erro inesperado: $e');
    return null;
  }
}

