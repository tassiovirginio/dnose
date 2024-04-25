import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

String src = r"""
import 'package:mistletoe/mistletoe.dart';
var o = new Object();
main(){
  f(o);
}
f(p){
  var o = p;
  o = o as Object;
  print(o);
}
""";

void detectCTL(String codigo) {
  if (codigo.contains("if") ||
      codigo.contains("for") ||
      codigo.contains("while")) {
    print("----------------------------");
    print("-- Conditional Test Logic --");
    print("----------------------------");
  }
}

void detectPSF(String codigo) {
  if (codigo.contains("print")) {
    print("----------------------------");
    print("--- PrintStatmentFixture ---");
    print("----------------------------");
  }
}

void detectSleep(String codigo) {
  if (codigo.contains("sleep")) {
    print("----------------------------");
    print("------- SleepyFixture ------");
    print("----------------------------");
  }
}

void main() async {
  var ast = parseFile(
          path:
              '/home/tassio/Desenvolvimento/Dart/teste01/test/teste01_test.dart',
          featureSet: FeatureSet.latestLanguageVersion())
      .unit;

  print(ast.toSource());

  AstNode astnode = ast.root;

  // astnode.childEntities.forEach((element) {
  //   print(element.toString() + "\n");
  // });

  astnode.childEntities.forEach((element) {
    // print(element.runtimeType);

    if (element is FunctionDeclaration) {
      print("Achei uma função...");

      element.childEntities.forEach((element) {
        // print(element.runtimeType);
        // print(element.toString());

        if (element is FunctionExpression) {
          element.childEntities.forEach((e) {
            // print(e.runtimeType);
            // print(e.toString());

            if (e is BlockFunctionBody) {
              e.childEntities.forEach((e) {
                // print(e.runtimeType);
                // print(e.toString());

                if (e is Block) {
                  e.childEntities.forEach((e) {
                    // print(e.runtimeType);
                    // print(e.toString());

                    if (e is ExpressionStatement) {
                      // print("->" + e.beginToken.toString());
                      // print(e.beginToken.type);

                      if (e.beginToken.toString() == "test" &&
                          e.beginToken.type == TokenType.IDENTIFIER) {
                        print("Achei um Teste...");
                        print(e.toSource());
                        detectCTL(e.toSource());
                        detectPSF(e.toSource());
                        detectSleep(e.toSource());
                      }

                      // e.childEntities.forEach((e) {
                      //   print(e.runtimeType);
                      //   print(e.toString());
                      // });
                    }
                  });
                }
              });
            }
          });
        }
      });
    }
  });
}
