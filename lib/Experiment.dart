import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

void main(List<String> args) {
  var ast = parseFile(
          path:
              '/home/tassio/Desenvolvimento/dart/dnose/test/oraculo_test.dart',
          featureSet: FeatureSet.latestLanguageVersion())
      .unit;

  detectar01(ast);
}

void detectar01(AstNode astnode) {
  // if (astnode is ForElement || astnode is IfElement ) {
  //   return;
  // }
  if (astnode is AstNode) {
    String code = astnode.toSource();
    print(astnode.runtimeType);
    print(astnode.toSource());

    if (astnode is SimpleStringLiteral &&
        astnode.parent is NamedExpression &&
        astnode.parent!.parent!.parent!.childEntities.firstOrNull!.toString() == "expect"){
      print("Teste....2");
      print("vazio => " + astnode.value.trim().isEmpty.toString());
      print("=> " + astnode.parent.toString());
      print("=> " + astnode.parent!.parent!.parent!.childEntities.firstOrNull!.toString());
    }

    if (code.contains(RegExp("\bexpect\b|\breason:|\"\""))) {
      print(astnode.runtimeType);
      print(astnode.toSource());
      // print(element.offset);
          // print(element.end);
          // print(element.length);
          // print(element.toSource());
          // print(element.toString());
      print("---------------------------------------------------");
    }
  }

  if (astnode.childEntities.isNotEmpty) {
    astnode.childEntities.forEach((element) {
      if (element is AstNode) {
        detectar01(element);
      }
    });
  }
}
//     astnode.childEntities.forEach((element) {