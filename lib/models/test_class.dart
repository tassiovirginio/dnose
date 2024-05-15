import 'package:analyzer/dart/ast/ast.dart' show AstNode, CompilationUnit;
import 'package:analyzer/dart/analysis/utilities.dart' show parseFile;
import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;

class TestClass {
  late CompilationUnit ast;
  late AstNode root;
  final String path, moduleAtual, projectName;

  TestClass({required this.path, required this.moduleAtual, required this.projectName}) {
    ast = parseFile(path: path, featureSet: FeatureSet.latestLanguageVersion())
        .unit;
    root = ast.root;
  }

  int lineNumber(int offset) => ast.lineInfo.getLocation(offset).lineNumber;
}
