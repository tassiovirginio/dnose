import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

extension NumberParsing on int {
  int lineNumber(int offset) {
    return ast.lineInfo.getLocation(offset).lineNumber;
  }
}

extension NumberParsing2 on AstNode {
  int lineNumberEnd() {
    return ast.lineInfo.getLocation(end).lineNumber;
  }
}

CompilationUnit ast = parseFile(
    path:
    '/home/tassio/Desenvolvimento/dart/dnose/test/oraculo_test.dart',
    featureSet: FeatureSet.latestLanguageVersion())
    .unit;

void main(List<String> args) {
  detectar01(ast);
}

int lineNumber(int offset) {
  return ast.lineInfo.getLocation(offset).lineNumber;
}

void detectar01(var astnode) {
  // if (astnode is ForElement || astnode is IfElement ) {
  //   return;
  // }
  if (astnode is AstNode) {
    String code = astnode.toSource();
    print(astnode.runtimeType);
    print(astnode.toSource());

    // if (astnode is SetOrMapLiteral && astnode.toString().replaceAll(" ", "") == "{}"
    // && astnode.parent!.parent!.parent!.parent!.childEntities.first.toString() == "test"){
    if (astnode is NamedExpression && astnode.parent is ArgumentList
        && astnode.toString().contains("skip: true")
        ){

      // int start = lineNumber(astnode.parent!.offset);
      // int end = lineNumber(astnode.parent!.end);


      print("Linha start: ${lineNumber(astnode.parent!.offset)}");
      print("Linha end: ${astnode.parent!.end.lineNumber}");
      print("Linha end: ${astnode.parent!.lineNumberEnd()}");
      print("1 => ${astnode.childEntities.isEmpty}");
      print("1 => $astnode");
      print("1.1 => ${astnode.toString().replaceAll(" ", "") == "{}"}");
      print("1 => ${astnode.runtimeType}");
      print("2 => ${astnode.parent}");
      print("2 => ${astnode.parent.runtimeType}");
      print("3 => ${astnode.parent!.parent}");
      print("3 => ${astnode.parent!.parent.runtimeType}");
      print("4 => ${astnode.parent!.parent!.parent}");
      print("4 => ${astnode.parent!.parent!.parent.runtimeType}");
      print("5 => ${astnode.parent!.parent!.parent!.parent}");
      print("5 => ${astnode.parent!.parent!.parent!.parent.runtimeType}");
      print("6 => ${astnode.parent!.parent!.parent!.parent!.childEntities.first}");
      // print("X => " + astnode.root.runtimeType.toString());
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

