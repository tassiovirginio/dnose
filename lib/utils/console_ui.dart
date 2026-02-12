import 'dart:io';
import 'dart:math';

/// Interface de console rica para o DNose (versão simplificada sem dependências externas)
class ConsoleUI {
  static final ConsoleUI _instance = ConsoleUI._internal();
  factory ConsoleUI() => _instance;
  ConsoleUI._internal();

  final DateTime _startTime = DateTime.now();

  // Códigos ANSI para cores
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';
  static const String _white = '\x1B[37m';
  static const String _gray = '\x1B[90m';

  // Estado
  String _currentProject = '';
  int _totalFiles = 0;
  int _processedFiles = 0;
  int _totalSmells = 0;
  final Map<String, int> _smellCounts = {};
  String _currentFile = '';
  bool _isProcessing = false;
  int _cacheAstSize = 0;
  int _cacheBlameSize = 0;
  int _cacheMd5Size = 0;
  int _lastPrintedLines = 0;

  /// Verifica se o terminal suporta cores ANSI
  bool get _supportsAnsi => stdout.supportsAnsiEscapes;

  /// Aplica cor ao texto
  String _color(String text, String colorCode) {
    return _supportsAnsi ? '$colorCode$text$_reset' : text;
  }

  String _c(String text) => _color(text, _cyan);
  String _g(String text) => _color(text, _green);
  String _y(String text) => _color(text, _yellow);
  String _r(String text) => _color(text, _red);
  String _m(String text) => _color(text, _magenta);
  String _w(String text) => _color(text, _white);
  String _gr(String text) => _color(text, _gray);

  /// Limpa a tela
  void clear() {
    if (_supportsAnsi) {
      stdout.write('\x1B[2J\x1B[0;0H');
    } else {
      print('\n' * 50);
    }
  }

  /// Mostra o banner inicial
  void showBanner() {
    clear();
    print('');
    print(_c('╔════════════════════════════════════════════════════════════╗'));
    print(_c('║                                                            ║'));
    print(
      _c('║') +
          '   🎯 DNose - Dart Test Smells Detector' +
          _c('                  ║'),
    );
    print(
      _c('║') +
          '   Detectando más práticas em testes Dart/Flutter' +
          _c('          ║'),
    );
    print(_c('║                                                            ║'));
    print(_c('╚════════════════════════════════════════════════════════════╝'));
    print('');
  }

  /// Inicia o processamento de um projeto
  void startProject(String projectName, int totalFiles) {
    _currentProject = projectName;
    _totalFiles = totalFiles;
    _processedFiles = 0;
    _totalSmells = 0;
    _smellCounts.clear();
    _isProcessing = true;
    _lastPrintedLines = 0;

    print(_m('📁 Projeto: ') + _w(projectName));
    print(_gr('   Arquivos de teste encontrados: $totalFiles'));
    print('');
  }

  /// Atualiza o progresso
  void updateProgress({
    required int processedFiles,
    required int totalSmells,
    required String currentFile,
    required Map<String, int> smellCounts,
    required int cacheAstSize,
    required int cacheBlameSize,
    required int cacheMd5Size,
  }) {
    _processedFiles = processedFiles;
    _totalSmells = totalSmells;
    _currentFile = currentFile;
    _smellCounts.addAll(smellCounts);
    _cacheAstSize = cacheAstSize;
    _cacheBlameSize = cacheBlameSize;
    _cacheMd5Size = cacheMd5Size;

    _renderProgress();
  }

  /// Renderiza a barra de progresso e estatísticas
  void _renderProgress() {
    // Limpa linhas anteriores
    if (_lastPrintedLines > 0 && _supportsAnsi) {
      for (var i = 0; i < _lastPrintedLines; i++) {
        stdout.write('\x1B[1A\x1B[2K');
      }
    }

    final percentage =
        _totalFiles > 0 ? (_processedFiles / _totalFiles * 100).round() : 0;
    final barWidth = 40;
    final filled = (percentage / 100 * barWidth).round();
    final empty = barWidth - filled;

    final progressBar = _g('█' * filled) + _gr('░' * empty);

    final lines = <String>[];
    lines.add('');
    lines.add(_c('   Progresso: [$progressBar] $percentage%'));
    lines.add(_gr('   Arquivos: $_processedFiles/$_totalFiles'));

    // Velocidade e ETA
    final elapsed = DateTime.now().difference(_startTime);
    final filesPerSecond =
        elapsed.inSeconds > 0 ? _processedFiles / elapsed.inSeconds : 0;
    final remainingFiles = _totalFiles - _processedFiles;
    final etaSeconds =
        filesPerSecond > 0 ? remainingFiles ~/ filesPerSecond : 0;

    lines.add(
      _gr('   Velocidade: ${filesPerSecond.toStringAsFixed(1)} arquivos/s'),
    );
    lines.add(_gr('   ETA: ${_formatDuration(Duration(seconds: etaSeconds))}'));
    lines.add('');

    // Arquivo atual
    if (_currentFile.isNotEmpty) {
      final fileName = _currentFile.split('/').last;
      lines.add(_y('   📄 $fileName'));
    }

    // Estatísticas de smells
    lines.add('');
    lines.add(_m('   📊 Test Smells encontrados: ') + _w('$_totalSmells'));

    if (_smellCounts.isNotEmpty) {
      final sortedSmells =
          _smellCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedSmells.take(5)) {
        final icon = _getSmellIcon(entry.key);
        final color = entry.value > 10 ? _r : (entry.value > 5 ? _y : _g);
        lines.add('      $icon ${entry.key}: ${color(entry.value.toString())}');
      }
    }

    // Cache info
    lines.add('');
    lines.add(
      _gr(
        '   💾 Cache: AST($_cacheAstSize) | Blame($_cacheBlameSize) | MD5($_cacheMd5Size)',
      ),
    );
    lines.add('');
    lines.add('');

    // Imprime todas as linhas
    for (var line in lines) {
      print(line);
    }

    _lastPrintedLines = lines.length;
  }

  /// Mostra o resumo final
  void showSummary({
    required int totalFiles,
    required int totalSmells,
    required Map<String, int> smellCounts,
    required Duration duration,
    required List<String> topFiles,
  }) {
    _isProcessing = false;
    clear();

    // Banner de conclusão
    print('');
    print(_g('╔════════════════════════════════════════════════════════════╗'));
    print(
      _g('║') +
          '   ✅ ANÁLISE CONCLUÍDA COM SUCESSO!' +
          _g('                       ║'),
    );
    print(_g('╚════════════════════════════════════════════════════════════╝'));
    print('');

    // Tabela de estatísticas gerais
    print(_c('📈 Estatísticas Gerais:'));
    print('');
    print(
      _createTable([
        ['Métrica', 'Valor'],
        ['📁 Arquivos analisados', totalFiles.toString()],
        ['🔍 Total de Test Smells', totalSmells.toString()],
        ['⏱️  Tempo total', _formatDuration(duration)],
        [
          '⚡ Velocidade média',
          '${(totalFiles / max(duration.inSeconds, 1)).toStringAsFixed(1)} arq/s',
        ],
      ]),
    );
    print('');

    // Tabela de smells por tipo
    if (smellCounts.isNotEmpty) {
      print(_c('📊 Test Smells por Tipo:'));
      print('');

      final sortedSmells =
          smellCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final smellTableData = [
        ['Tipo', 'Quantidade', 'Porcentagem'],
      ];

      for (var entry in sortedSmells) {
        final percentage =
            totalSmells > 0
                ? (entry.value / totalSmells * 100).toStringAsFixed(1)
                : '0.0';
        smellTableData.add([
          _getSmellIcon(entry.key) + ' ' + entry.key,
          entry.value.toString(),
          '$percentage%',
        ]);
      }

      print(_createTable(smellTableData));
      print('');
    }

    // Top arquivos com mais smells
    if (topFiles.isNotEmpty) {
      print(_y('🏆 Top Arquivos com mais Test Smells:'));
      print('');
      for (var i = 0; i < topFiles.length && i < 5; i++) {
        print('   ${i + 1}. ${topFiles[i]}');
      }
      print('');
    }

    // Arquivos gerados
    print(_g('📁 Arquivos gerados:'));
    print('   • resultado.csv - Detalhes dos smells');
    print('   • resultado2.csv - Resumo por tipo');
    print('   • resultado_metrics.csv - Métricas detalhadas');
    print('   • resultado.sqlite - Banco de dados SQLite');
    print('');
  }

  /// Mostra um erro
  void showError(String message) {
    print('');
    print(_r('❌ ERRO: $message'));
    print('');
  }

  /// Mostra uma mensagem de aviso
  void showWarning(String message) {
    print(_y('⚠️  $message'));
  }

  /// Mostra uma mensagem informativa
  void showInfo(String message) {
    print(_c('ℹ️  $message'));
  }

  /// Mostra o modo de uso
  void showUsage() {
    print('');
    print(_w('Uso: dnose <comando> [opções]'));
    print('');
    print(_c('Comandos:'));
    print('   analyze <path>     Analisa um projeto ou pasta');
    print('   analyze-all        Analisa todos os projetos na pasta projects/');
    print('   server             Inicia o servidor web');
    print('   version            Mostra a versão');
    print('   help               Mostra esta ajuda');
    print('');
    print(_c('Opções:'));
    print('   --verbose, -v      Modo verboso com mais detalhes');
    print('   --workers, -w N    Número de workers paralelos (padrão: 4)');
    print('   --no-cache         Desabilita cache de AST');
    print('');
  }

  /// Mostra a versão
  void showVersion() {
    print(_c('DNose v1.0.0'));
    print(_gr('Dart Test Smells Detector'));
    print(_gr('https://github.com/tassiovirginio/dnose'));
  }

  /// Retorna um ícone para o tipo de smell
  String _getSmellIcon(String smellName) {
    final icons = {
      'Assertion Roulette': '🎲',
      'Conditional Test Logic': '🔀',
      'Duplicate Assert': '🔄',
      'Empty Test': '📭',
      'Exception Handling': '⚠️',
      'Ignored Test': '🚫',
      'Magic Number': '🔢',
      'Print Statment Fixture': '🖨️',
      'Resource Optimism': '📁',
      'Sensitive Equality': '🔍',
      'Sleepy Fixture': '💤',
      'Test Without Description': '📝',
      'Unknown Test': '❓',
      'Verbose Test': '📜',
    };
    return icons[smellName] ?? '•';
  }

  /// Formata uma duração para exibição
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Cria uma tabela ASCII formatada
  String _createTable(List<List<String>> rows) {
    if (rows.isEmpty) return '';

    // Calcula larguras das colunas
    final colCount = rows.first.length;
    final colWidths = List<int>.filled(colCount, 0);

    for (var row in rows) {
      for (var i = 0; i < row.length && i < colCount; i++) {
        colWidths[i] = max(colWidths[i], row[i].length);
      }
    }

    // Adiciona padding
    for (var i = 0; i < colWidths.length; i++) {
      colWidths[i] += 2;
    }

    final buffer = StringBuffer();

    // Linha superior
    buffer.write('┌');
    for (var i = 0; i < colCount; i++) {
      buffer.write('─' * colWidths[i]);
      if (i < colCount - 1) buffer.write('┬');
    }
    buffer.write('┐\n');

    // Linhas de dados
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      buffer.write('│');
      for (var i = 0; i < colCount; i++) {
        final cell = i < row.length ? row[i] : '';
        final padding = colWidths[i] - cell.length;
        final leftPad = padding ~/ 2;
        final rightPad = padding - leftPad;
        buffer.write(' ' * leftPad + cell + ' ' * rightPad + '│');
      }
      buffer.write('\n');

      // Linha separadora após cabeçalho
      if (rowIndex == 0 && rows.length > 1) {
        buffer.write('├');
        for (var i = 0; i < colCount; i++) {
          buffer.write('─' * colWidths[i]);
          if (i < colCount - 1) buffer.write('┼');
        }
        buffer.write('┤\n');
      }
    }

    // Linha inferior
    buffer.write('└');
    for (var i = 0; i < colCount; i++) {
      buffer.write('─' * colWidths[i]);
      if (i < colCount - 1) buffer.write('┴');
    }
    buffer.write('┘');

    return buffer.toString();
  }

  /// Pausa e espera uma tecla
  void pause() {
    print('');
    print(_gr('Pressione ENTER para continuar...'));
    stdin.readLineSync();
  }
}
