import 'dart:io';

void main() async {

  String arquivo = '/home/tassio/Desenvolvimento/repo.git/dnose/bin/server.dart';
  String workingDirectory = '/home/tassio/Desenvolvimento/repo.git/dnose';

  List<BlameLine> lista = runApp(arquivo, workingDirectory);

  for (var linha in lista) {
    print(linha);
  }
}

class BlameLine{
  String? lineNumber, commit, author, dateStr, timeStr, summary;
  BlameLine(this.lineNumber, this.commit, this.author, this.dateStr, this.timeStr, this.summary);
  @override
  String toString() {
    return '$lineNumber|$commit|$author|$dateStr|$timeStr|$summary';
  }
}

List<BlameLine> runApp(String arquivo, String workingDirectory) {

  List<BlameLine> lista = List.empty(growable: true);

  final check =
      Process.runSync('git', ['ls-files', '--error-unmatch', arquivo]);
  if (check.exitCode != 0) {
    print("Erro: O arquivo '$arquivo' não está sob controle do git.");
    exit(2);
  }

  final result = Process.runSync('git', ['blame', '--line-porcelain', arquivo], workingDirectory: workingDirectory);
  if (result.exitCode != 0) {
    print('Erro ao executar git blame.');
    exit(3);
  }

  String? commit;
  String? author;
  String? dateStr;
  String? timeStr;
  String? summary;
  String? lineNumber;

  final lines = result.stdout.toString().split('\n');

  for (final line in lines) {
    if (line.length > 40 && RegExp(r'^[a-fA-F0-9]{40} ').hasMatch(line)) {
      final parts = line.split(' ');
      commit = parts[0].substring(0, 8); // encurta o hash
      lineNumber = parts.length > 2 ? parts[2] : null;
    } else if (line.startsWith('author ')) {
      author = line.substring('author '.length);
    } else if (line.startsWith('author-time ')) {
      final timestamp = int.tryParse(line.substring('author-time '.length));
      if (timestamp != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        dateStr =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        timeStr =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      }
    } else if (line.startsWith('summary ')) {
      summary = line.substring('summary '.length);
    } else if (line.startsWith('\t')) {
      if ([commit, author, dateStr, timeStr, summary, lineNumber]
          .every((e) => e != null)) {
        lista.add(BlameLine(lineNumber, commit, author, dateStr, timeStr, summary));
      }
      commit = author = dateStr = timeStr = summary = lineNumber = null;
    }
  }

  return lista;
}
