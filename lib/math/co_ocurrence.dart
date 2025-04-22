import 'dart:io';

void main() async {
  // 1. Ler o arquivo CSV
  final file = File('/home/tassio/testsmells_202411261748.csv');

  final Map<String, List<String>> pathToSmells = {};

  try {
    // Lê o arquivo linha por linha de forma síncrona
    List<String> lines = file.readAsLinesSync();

    int cont = 0;

    // Imprime cada linha do arquivo
    for (var line in lines) {
      // print(line);
      if(cont > 0){
        final path = line.split(",")[0];
        final testsmell = line.split(",")[1];
        pathToSmells.putIfAbsent(path, () => []).add(testsmell);
      }else{
        cont++;
      }
    }
  } catch (e) {
    print('Erro ao ler o arquivo: $e');
  }


  // print(pathToSmells);

  // 3. Criar matriz de co-ocorrência
  final allTestSmells = pathToSmells.values.expand((x) => x).toSet();
  final Map<String, Map<String, int>> coOccurrence = {};

  for (var smell1 in allTestSmells) {
    coOccurrence[smell1] = {};
    for (var smell2 in allTestSmells) {
      coOccurrence[smell1]![smell2] = 0; // Inicializa com 0
    }
  }

  for (var smells in pathToSmells.values) {
    for (var smell1 in smells) {
      for (var smell2 in smells) {
        if (smell1 != smell2) {
          coOccurrence[smell1]![smell2] = (coOccurrence[smell1]![smell2] ?? 0) + 1;
        }
      }
    }
  }

  // 4. Imprimir matriz de co-ocorrência
  print('Co-ocorrência de Test Smells:');
  for (var row in coOccurrence.entries) {
    print('${row.key}: ${row.value}');
  }
}
