import 'package:analyzer/dart/ast/ast.dart' show AstNode, CompilationUnit;
import 'package:analyzer/dart/analysis/utilities.dart' show parseFile;
import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:dnose/utils/lru_cache.dart';

class TestClass {
  late CompilationUnit ast;
  late AstNode root;
  late final String path, moduleAtual, projectName, commit;

  // LRU Cache para ASTs - capacidade de 100 arquivos
  static final _astCache = LruCache<String, CompilationUnit>(capacity: 100);

  TestClass({
    required this.commit,
    required this.path,
    required this.moduleAtual,
    required this.projectName,
  }) {
    _initAst();
    root = ast.root;
  }

  TestClass.test(this.path) {
    commit = "";
    moduleAtual = "";
    projectName = "";
    _initAst();
    root = ast.root;
  }

  void _initAst() {
    // Verifica cache primeiro
    final cached = _astCache.get(path);
    if (cached != null) {
      ast = cached;
      return;
    }

    // Parse e armazena no cache
    ast =
        parseFile(
          path: path,
          featureSet: FeatureSet.latestLanguageVersion(),
        ).unit;
    _astCache.set(path, ast);
  }

  int lineNumber(int offset) => ast.lineInfo.getLocation(offset).lineNumber;
  int columnNumber(int offset) => ast.lineInfo.getLocation(offset).columnNumber;

  /// Limpa o cache de AST (útil para testes ou quando memória é crítica)
  static void clearCache() => _astCache.clear();

  /// Retorna o tamanho atual do cache
  static int get cacheSize => _astCache.length;
}
