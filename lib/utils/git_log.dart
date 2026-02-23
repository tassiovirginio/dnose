import 'dart:io';

import 'package:path/path.dart' as path;

Future<File> generateGitLogCsv(repoPath, outputDir) async {
  // Obtém o nome do projeto
  final projectName = _getProjectName(repoPath);
  // print('📁 Projeto: $projectName');

  // Cria diretório de saída se não existir
  final dir = Directory(outputDir);
  if (!await dir.exists()) {
    // print('📂 Criando diretório de saída...');
    await dir.create(recursive: true);
  }

  // Caminho completo do arquivo CSV
  final csvPath = path.join(outputDir, 'commits.csv');
  // print('💾 Arquivo de saída: $csvPath');

  // Executa o comando git log\n  // print('🔄 Extraindo commits do repositório...');
  final process = await Process.run('git', [
    'log',
    '--pretty=format:%H|||%an|||%ad|||%s',
    '--date=iso',
  ], workingDirectory: repoPath);

  if (process.exitCode != 0) {
    throw Exception('❌ Erro no git log: ${process.stderr}');
  }

  // Processa a saída e adiciona o nome do projeto
  // print('✏️ Formatando CSV...');
  var output = process.stdout.toString();
  output = output.replaceAll(";", ".").replaceAll('"', "").replaceAll(",", ".");
  output = output.replaceAll("|||", ";");
  final lines = output.split('\n');
  final csvContent =
      StringBuffer()..writeln('project;hash;author;date;message'); // Cabeçalho

  for (final line in lines) {
    if (line.trim().isNotEmpty) {
      csvContent.writeln('$projectName;$line');
    }
  }

  // Salva o arquivo
  // print('💿 Salvando arquivo...');
  final csvFile = File(csvPath);
  final writeMode = await csvFile.exists() ? FileMode.append : FileMode.write;
  await csvFile.writeAsString(csvContent.toString(), mode: writeMode);

  return csvFile;
}

String _getProjectName(String repoPath) {
  return path.basename(repoPath.replaceAll(RegExp(r'[/\\]+$'), ''));
}
