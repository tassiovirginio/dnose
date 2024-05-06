import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
// import 'package:analyzer/dart/analysis/results.dart';

class TestClass {
  CompilationUnit? ast;
  String path = "";
  AstNode? root;
  String? project;

  TestClass(String path, String project) {
    this.path = path;
    this.ast = parseFile(
            path: path, featureSet: FeatureSet.latestLanguageVersion())
        .unit;
    this.project = project;
    root = ast?.root;
  }
}
