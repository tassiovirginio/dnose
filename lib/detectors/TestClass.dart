import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
// import 'package:analyzer/dart/analysis/results.dart';

class TestClass {
  CompilationUnit? ast;
  String path = "";
  AstNode? root;
  String? module_atual;
  String? project_name;

  TestClass(String path, String module_atual, String project_name) {
    this.path = path;
    this.ast = parseFile(
            path: path, featureSet: FeatureSet.latestLanguageVersion())
        .unit;
    this.module_atual = module_atual;
    this.project_name = project_name;
    root = ast?.root;
  }
}
