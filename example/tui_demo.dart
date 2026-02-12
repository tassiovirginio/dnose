import 'dart:io';
import 'package:dnose/utils/console_ui.dart';

void main() async {
  final ui = ConsoleUI();

  // Mostra banner
  ui.showBanner();

  // Simula processamento de um projeto
  ui.startProject('my_flutter_app', 50);

  // Simula progresso
  final smellCounts = <String, int>{};
  for (var i = 0; i <= 50; i++) {
    await Future.delayed(Duration(milliseconds: 100));

    // Adiciona smells aleatórios
    if (i % 5 == 0) {
      final smells = [
        'Assertion Roulette',
        'Magic Number',
        'Conditional Test Logic',
      ];
      final smell = smells[i % smells.length];
      smellCounts[smell] = (smellCounts[smell] ?? 0) + (i % 3 + 1);
    }

    ui.updateProgress(
      processedFiles: i,
      totalSmells: smellCounts.values.fold(0, (a, b) => a + b),
      currentFile: '/path/to/test_$i.dart',
      smellCounts: smellCounts,
      cacheAstSize: i ~/ 2,
      cacheBlameSize: i ~/ 3,
      cacheMd5Size: i * 10,
    );
  }

  // Mostra resumo final
  ui.showSummary(
    totalFiles: 50,
    totalSmells: smellCounts.values.fold(0, (a, b) => a + b),
    smellCounts: smellCounts,
    duration: Duration(seconds: 5),
    topFiles: [
      'test/widget_test.dart (15 smells)',
      'test/unit_test.dart (12 smells)',
      'test/integration_test.dart (8 smells)',
    ],
  );
}
