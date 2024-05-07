import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

CompilationUnit ast = parseFile(
    path:
    '/home/tassio/Desenvolvimento/dart/dnose/test/oraculo_test.dart',
    featureSet: FeatureSet.latestLanguageVersion())
    .unit;

void main(List<String> args) {
  detectar01(ast);
}

int lineNumber(int offset) {
  return ast.lineInfo.getLocation(offset).lineNumber ?? 0;
}

void detectar01(AstNode astnode) {
  // if (astnode is ForElement || astnode is IfElement ) {
  //   return;
  // }
  if (astnode is AstNode) {
    String code = astnode.toSource();
    print(astnode.runtimeType);
    print(astnode.toSource());

    if (astnode is SimpleIdentifier && astnode.toString() == "test" && astnode.parent is MethodInvocation){

      int start = lineNumber(astnode.parent!.offset);
      int end = lineNumber(astnode.parent!.end);


      print("Linha start: " + lineNumber(astnode.parent!.offset).toString());
      print("Linha end: " + lineNumber(astnode.parent!.end).toString());
      print("1 => " + astnode.toString());
      print("3 => " + astnode.runtimeType.toString());
      print("2 => " + astnode.parent.toString());
      print("3 => " + astnode.parent.runtimeType.toString());
      print("2 => " + astnode.parent!.childEntities.first.toString());
      print("X => " + astnode.root.runtimeType.toString());
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