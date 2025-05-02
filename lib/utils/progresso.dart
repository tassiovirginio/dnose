import 'dart:io';

class Progresso {
  static String _barra = '';
  static int _progresso = 0;
  static int _tamanhoBarra = 50;
  static String project = '';
  static bool _coresDisponiveis = true;
  static bool _finalizado = false;

  static void setProject(String projeto) {
    project = projeto;
    _barra = '';
    _progresso = 0;
    _finalizado = false;
    _coresDisponiveis = stdout.supportsAnsiEscapes;
  }

  static void adicionarBloco() {
    if (_finalizado) return;

    _progresso += 1;

    if (_progresso > 100) {
      _progresso = 100;
    }

    final blocosCompletos = (_progresso * _tamanhoBarra) ~/ 100;
    _barra = '█' * blocosCompletos;
    final espacos = ' ' * (_tamanhoBarra - blocosCompletos);

    final porcentagem = '${_progresso.toString().padLeft(3)}%';

    if (_coresDisponiveis) {
      _limparLinha();
      stdout.write('\r\x1B[36m$project\x1B[0m [\x1B[32m$_barra\x1B[0m$espacos] $porcentagem');
    } else {
      _limparLinha();
      stdout.write('\r$project [$_barra$espacos] $porcentagem');
    }
  }

  static void resetar() {
    _barra = '';
    _progresso = 0;
    _finalizado = false;
    _limparLinha();
    stdout.write('\r${' ' * (project.length + _tamanhoBarra + 10)}\r');
  }

  static void finalizado() {
    if (_finalizado) return;

    // Completa a barra
    _progresso = 100;
    _barra = '█' * _tamanhoBarra;

    // Limpa a linha atual
    _limparLinha();
    stdout.write('\r${' ' * (project.length + _tamanhoBarra + 10)}\r');

    if (_coresDisponiveis) {
      // Versão colorida
      _limparLinha();
      stdout.write('\r\x1B[32m✓ Process completed successfully!\x1B[0m');
    } else {
      // Versão sem cores
      _limparLinha();
      stdout.write('\r✓ Process completed successfully!');
    }

    _finalizado = true;
  }

  static void _limparLinha() {
    stdout.write('\r${' ' * (100)}\r');
  }
}