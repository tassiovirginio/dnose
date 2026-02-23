import 'dart:async';
import 'dart:io';

/// Rich TUI dashboard for DNose — replaces the old Progresso class.
///
/// Uses ANSI escape codes to render a live-updating dashboard
/// with project/file progress bars, spinner, counters and detection log.
class DnoseTui {
  // ── Singleton state ──
  static bool _active = false;
  static bool _ansi = true;
  static Timer? _timer;

  // ── Progress state ──
  static int _totalProjects = 0;
  static int _completedProjects = 0;
  static String _currentProject = '';
  static int _totalFiles = 0;
  static int _completedFiles = 0;
  static int _totalSmells = 0;
  static int _totalFilesAnalyzed = 0;
  static int _activeWorkers = 0;
  static int _maxWorkers = 0;

  // ── Timing ──
  static late DateTime _startTime;

  // ── Spinner ──
  static const _spinChars = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  static int _spinIdx = 0;

  // ── Detection log (last 5) ──
  static final List<String> _recentDetections = [];
  static const int _maxDetections = 5;

  // ── Dashboard dimensions ──
  static const int _barWidth = 30;
  static const int _boxInner = 62; // visible columns between ║ and ║
  static int _renderedLines = 0;

  // ── ANSI helpers ──
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _dim = '\x1B[2m';
  static const _cyan = '\x1B[36m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
  static const _white = '\x1B[37m';
  static const _hideCursor = '\x1B[?25l';
  static const _showCursor = '\x1B[?25h';

  /// Initialize the TUI dashboard before processing starts.
  static void init({required int totalProjects, int maxWorkers = 0}) {
    _ansi = stdout.supportsAnsiEscapes;
    _totalProjects = totalProjects;
    _completedProjects = 0;
    _currentProject = '';
    _totalFiles = 0;
    _completedFiles = 0;
    _totalSmells = 0;
    _totalFilesAnalyzed = 0;
    _activeWorkers = 0;
    _maxWorkers = maxWorkers > 0 ? maxWorkers : Platform.numberOfProcessors;
    _startTime = DateTime.now();
    _recentDetections.clear();
    _spinIdx = 0;
    _renderedLines = 0;
    _active = true;

    if (_ansi) {
      stdout.write(_hideCursor);
    }

    // Render timer — updates spinner + elapsed time every 120ms
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _spinIdx = (_spinIdx + 1) % _spinChars.length;
      _render();
    });

    _render();
  }

  /// Call when starting a new project.
  static void startProject(String name, int totalFiles) {
    _currentProject = name;
    _totalFiles = totalFiles;
    _completedFiles = 0;
    _render();
  }

  /// Call when a file finishes processing.
  static void fileCompleted() {
    _completedFiles++;
    _totalFilesAnalyzed++;
    _render();
  }

  /// Call when a test smell is detected.
  static void smellDetected(String smellName, String fileName, int line) {
    _totalSmells++;
    final basename = fileName.split('/').last;
    final entry = '$smellName → $basename:$line';
    _recentDetections.insert(0, entry);
    if (_recentDetections.length > _maxDetections) {
      _recentDetections.removeLast();
    }
  }

  /// Update active worker count.
  static void setActiveWorkers(int count) {
    _activeWorkers = count;
  }

  /// Call when a project finishes processing.
  static void projectCompleted() {
    _completedProjects++;
    _render();
  }

  /// Call when all processing is done.
  static void finish() {
    _timer?.cancel();
    _timer = null;
    _active = false;

    // Final render
    _completedFiles = _totalFiles;
    _render();

    if (_ansi) {
      stdout.writeln();
      stdout.write(_showCursor);

      final elapsed = _formatElapsed();
      stdout.writeln();
      stdout.writeln('$_green$_bold  ✓ Análise concluída!$_reset');
      stdout.writeln(
        '$_dim  $_totalSmells smells encontrados '
        'em $_totalFilesAnalyzed arquivos '
        '($_completedProjects projetos) — $elapsed$_reset',
      );
      stdout.writeln();
    } else {
      stdout.writeln();
      stdout.writeln('✓ Análise concluída!');
      stdout.writeln(
        '  $_totalSmells smells encontrados '
        'em $_totalFilesAnalyzed arquivos '
        '($_completedProjects projetos)',
      );
    }
  }

  // ── Rendering ──────────────────────────────────────────────

  static void _render() {
    if (!_active) return;

    if (_ansi) {
      _renderAnsi();
    } else {
      _renderPlain();
    }
  }

  static void _renderAnsi() {
    final buf = StringBuffer();

    // Move cursor up to overwrite previous frame
    if (_renderedLines > 0) {
      buf.write('\x1B[${_renderedLines}A\r');
    }

    int lines = 0;
    final border = '═' * _boxInner;

    // ── Top border ──
    buf.writeln('$_cyan$_bold╔$border╗$_reset');
    lines++;

    // ── Header ──
    buf.writeln(
      _line(
        '  🔍 $_cyan${_bold}DNose v1.0.0$_reset $_dim— Dart Test Smell Detector$_reset',
      ),
    );
    lines++;

    // ── Separator ──
    buf.writeln('$_cyan$_bold╠$border╣$_reset');
    lines++;

    // ── Project progress ──
    final projPct =
        _totalProjects > 0
            ? (_completedProjects / _totalProjects * 100).round()
            : 0;
    final projBar = _buildBar(_completedProjects, _totalProjects);
    final projNums = '$_completedProjects/$_totalProjects';
    buf.writeln(
      _line('  📊 Projetos    $projBar  $projNums  ${_pctStr(projPct)}'),
    );
    lines++;

    // ── File progress ──
    final filePct =
        _totalFiles > 0 ? (_completedFiles / _totalFiles * 100).round() : 0;
    final fileBar = _buildBar(_completedFiles, _totalFiles);
    final fileNums = '$_completedFiles/$_totalFiles';
    final spin = _spinChars[_spinIdx];
    final spinDisplay =
        _completedFiles < _totalFiles
            ? '$_yellow$spin$_reset'
            : '$_green✓$_reset';
    buf.writeln(
      _line(
        '  📁 Arquivos    $fileBar  $fileNums  ${_pctStr(filePct)}  $spinDisplay',
      ),
    );
    lines++;

    // ── Empty line ──
    buf.writeln(_line(''));
    lines++;

    // ── Current project ──
    final projName = _truncate(_currentProject, 42);
    buf.writeln(_line('  📦 Projeto: $_yellow$_bold$projName$_reset'));
    lines++;

    // ── Stats line 1 ──
    final elapsed = _formatElapsed();
    final workersStr = '$_activeWorkers/$_maxWorkers';
    buf.writeln(
      _line(
        '  ⏱  Tempo: $_white$elapsed$_reset      🧵 Workers: $_white$workersStr$_reset',
      ),
    );
    lines++;

    // ── Stats line 2 ──
    final smellStr = _totalSmells.toString();
    final filesStr = _totalFilesAnalyzed.toString();
    buf.writeln(
      _line(
        '  🐛 Smells: $_red$_bold$smellStr$_reset          📄 Analisados: $_white$filesStr$_reset',
      ),
    );
    lines++;

    // ── Separator ──
    buf.writeln('$_cyan$_bold╠$border╣$_reset');
    lines++;

    // ── Recent detections ──
    buf.writeln(_line('  $_dim Últimas detecções:$_reset'));
    lines++;

    for (int i = 0; i < _maxDetections; i++) {
      if (i < _recentDetections.length) {
        final prefix = i < _recentDetections.length - 1 ? '├─' : '└─';
        final det = _truncate(_recentDetections[i], 50);
        buf.writeln(_line('  $_dim$prefix$_reset $_yellow⚠$_reset $det'));
      } else {
        buf.writeln(_line(''));
      }
      lines++;
    }

    // ── Bottom border ──
    buf.writeln('$_cyan$_bold╚$border╝$_reset');
    lines++;

    _renderedLines = lines;
    stdout.write(buf);
  }

  static void _renderPlain() {
    final projPct =
        _totalProjects > 0
            ? (_completedProjects / _totalProjects * 100).round()
            : 0;
    final filePct =
        _totalFiles > 0 ? (_completedFiles / _totalFiles * 100).round() : 0;
    stdout.write(
      '\r[$_currentProject] '
      'Projetos: $_completedProjects/$_totalProjects ($projPct%) '
      'Arquivos: $_completedFiles/$_totalFiles ($filePct%) '
      'Smells: $_totalSmells',
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  /// Build a single boxed line:  ║ content + padding ║
  /// Padding is calculated from the *visible* width of content.
  static String _line(String content) {
    final vw = _visibleWidth(content);
    final pad = _boxInner - vw;
    final spaces = pad > 0 ? ' ' * pad : '';
    return '$_cyan$_bold║$_reset$content$spaces$_cyan$_bold║$_reset';
  }

  /// Calculate visible terminal width of a string.
  /// Strips ANSI escape sequences and counts wide chars (emoji) as 2 columns.
  static int _visibleWidth(String s) {
    // Strip ANSI escape codes
    final stripped = s.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');
    int width = 0;
    for (final rune in stripped.runes) {
      width += _isWideChar(rune) ? 2 : 1;
    }
    return width;
  }

  /// Returns true if a Unicode code point occupies 2 terminal columns.
  static bool _isWideChar(int cp) {
    // Miscellaneous Symbols and Pictographs, Emoticons, etc.
    if (cp >= 0x1F300 && cp <= 0x1F9FF) return true;
    // Supplemental Symbols and Pictographs
    if (cp >= 0x1FA00 && cp <= 0x1FA6F) return true;
    // Misc Symbols (☀ ⚠ etc.)
    if (cp >= 0x2600 && cp <= 0x27BF) return true;
    // Dingbats
    if (cp >= 0x2702 && cp <= 0x27B0) return true;
    // Enclosed Alphanumeric Supplement
    if (cp >= 0x1F100 && cp <= 0x1F1FF) return true;
    // CJK
    if (cp >= 0x4E00 && cp <= 0x9FFF) return true;
    if (cp >= 0x3000 && cp <= 0x303F) return true;
    // Fullwidth Forms
    if (cp >= 0xFF01 && cp <= 0xFF60) return true;
    return false;
  }

  static String _buildBar(int current, int total) {
    final filled = total > 0 ? (current / total * _barWidth).round() : 0;
    final empty = _barWidth - filled;
    return '$_green${'█' * filled}$_dim${'░' * empty}$_reset';
  }

  static String _pctStr(int pct) {
    return '${pct.toString().padLeft(3)}%';
  }

  static String _truncate(String s, int maxLen) {
    if (_visibleWidth(s) <= maxLen) return s;
    String result = s;
    while (_visibleWidth(result) > maxLen - 1 && result.isNotEmpty) {
      result = result.substring(0, result.length - 1);
    }
    return '$result…';
  }

  static String _formatElapsed() {
    final d = DateTime.now().difference(_startTime);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
