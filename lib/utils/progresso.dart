import 'package:dnose/models/test_class.dart';
import 'package:dnose/utils/blame.dart';
import 'package:dnose/utils/console_ui.dart';
import 'package:dnose/utils/util.dart';

/// Sistema de progresso aprimorado com ConsoleUI
class Progresso {
  static String project = '';
  static bool _finalizado = false;
  static final ConsoleUI _ui = ConsoleUI();

  // Estatísticas acumuladas
  static int _totalFiles = 0;
  static int _processedFiles = 0;
  static int _totalSmells = 0;
  static final Map<String, int> _smellCounts = {};
  static String _currentFile = '';

  static void setProject(String projeto) {
    project = projeto;
    _finalizado = false;
    _totalFiles = 0;
    _processedFiles = 0;
    _totalSmells = 0;
    _smellCounts.clear();
    _currentFile = '';
  }

  static void setTotalFiles(int total) {
    _totalFiles = total;
  }

  static void adicionarBloco() {
    if (_finalizado) return;
    _processedFiles++;
    _updateUI();
  }

  static void updateFile(String filePath) {
    _currentFile = filePath;
    _updateUI();
  }

  static void addSmells(List<dynamic> smells) {
    _totalSmells += smells.length;
    for (var smell in smells) {
      final name = smell.name.toString();
      _smellCounts[name] = (_smellCounts[name] ?? 0) + 1;
    }
    _updateUI();
  }

  static void _updateUI() {
    if (_totalFiles == 0) return;

    _ui.updateProgress(
      processedFiles: _processedFiles,
      totalSmells: _totalSmells,
      currentFile: _currentFile,
      smellCounts: _smellCounts,
      cacheAstSize: TestClass.cacheSize,
      cacheBlameSize: BlameCache.size,
      cacheMd5Size: Util.md5CacheSize,
    );
  }

  static void resetar() {
    _finalizado = false;
    _totalFiles = 0;
    _processedFiles = 0;
    _totalSmells = 0;
    _smellCounts.clear();
    _currentFile = '';
  }

  static void finalizado() {
    if (_finalizado) return;
    _finalizado = true;
  }

  static bool get isFinalizado => _finalizado;

  static int get totalFiles => _totalFiles;
  static int get processedFiles => _processedFiles;
  static int get totalSmells => _totalSmells;
  static Map<String, int> get smellCounts => Map.unmodifiable(_smellCounts);
}
