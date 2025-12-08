import 'package:analyzer/dart/ast/ast.dart' show AstNode, CompilationUnit;
import 'package:analyzer/dart/analysis/utilities.dart' show parseFile;
import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:path/path.dart' as p;

class TestClass {
  late CompilationUnit ast;
  late AstNode root;
  late final String path, moduleAtual, projectName, commit;

  TestClass({
    required this.commit,
    required this.path,
    required this.moduleAtual,
    required this.projectName,
  }) {
    ast =
        parseFile(
          path: path,
          featureSet: FeatureSet.latestLanguageVersion(),
        ).unit;
    root = ast.root;
  }

  TestClass.test(this.path) {
    commit = "";
    moduleAtual = "";
    projectName = "";
    ast =
        parseFile(
          path: p.normalize(path),
          featureSet: FeatureSet.latestLanguageVersion(),
        ).unit;
    root = ast.root;
  }

  int lineNumber(int offset) => ast.lineInfo.getLocation(offset).lineNumber;
  int columnNumber(int offset) => ast.lineInfo.getLocation(offset).columnNumber;
}
