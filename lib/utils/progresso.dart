import 'dart:io';

class Progresso {
  static String _barra = '';
  static int _total = 0;
  static String project = '';

  static void setProject(String projeto) {
    project = projeto;
    _barra = '';
  }

  static void adicionarBloco() {
    if(_total > 100){
      _total = 0;
      // stdout.write('\n');
      resetar();
    }else{
      _total += 1;
      _barra += '█';
      stdout.write('\r$project $_barra');
    }
  }

  static void resetar() {
    _barra = '';
    // print(''); // Nova linha
  }

  static void finalizado() {
    _barra = '';
    stdout.write('\r████████████████ Concluído ████████████████');
  }
}