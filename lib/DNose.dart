import 'dart:ffi';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:teste01/TestSmell.dart';

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

List<TestSmell> testSmells = List.empty(growable: true);

void detectCTL(ExpressionStatement e) {
  String codigo = e.toSource();
  if (codigo.contains("if") ||
      codigo.contains("for") ||
      codigo.contains("while")) {
    TestSmell testSmell = TestSmell();
    testSmell.name = "Conditional Test Logic";
    testSmells.add(testSmell);
    print("----------------------------");
    print("-- Conditional Test Logic --");
    print("----------------------------");
  }
}

void detectPSF(ExpressionStatement e) {
  String codigo = e.toSource();
  if (codigo.contains("print")) {
    TestSmell testSmell = TestSmell();
    testSmell.name = "PrintStatmentFixture";
    testSmells.add(testSmell);
    print("----------------------------");
    print("--- PrintStatmentFixture ---");
    print("----------------------------");
  }
}

void detectSleep(ExpressionStatement e) {
  String codigo = e.toSource();
  if (codigo.contains("sleep")) {
    TestSmell testSmell = TestSmell();
    testSmell.name = "SleepyFixture";
    testSmells.add(testSmell);
    print("----------------------------");
    print("------- SleepyFixture ------");
    print("----------------------------");
  }
}

void testWithoutDescription(ExpressionStatement e) {
  e.childEntities.forEach((element) {
    if (element is MethodInvocation) {
      element.childEntities.forEach((e2) {
        if (e2 is ArgumentList) {
          e2.childEntities.forEach((e3) {
            if (e3 is SimpleStringLiteral) {
              if (e3.value.trim().isEmpty) {
                TestSmell testSmell = TestSmell();
                testSmell.name = "TestWithoutDescription";
                testSmells.add(testSmell);
                print("----------------------------");
                print("-- TestWithoutDescription --");
                print("----------------------------");
              }
            }
            // print(
            //     "---> " + e3.toString() + " ---- " + e3.runtimeType.toString());
          });
        }
      });
    }
  });
}

void magicNumber(AstNode e) {
  if (e is IntegerLiteral || e is DoubleLiteral) {
    TestSmell testSmell = TestSmell();
    testSmell.name = "Magic Number";
    testSmells.add(testSmell);
    print("----------------------------");
    print("------- Magic Number -------");
    print("----------------------------");
  } else {
    e.childEntities.forEach((element) {
      if (element is AstNode) {
        magicNumber(element);
      }
    });
  }
}

void magicNumber2(ExpressionStatement e) {
  e.childEntities.forEach((element) {
    if (element is MethodInvocation) {
      element.childEntities.forEach((e2) {
        if (e2 is ArgumentList) {
          e2.childEntities.forEach((e3) {
            if (e3 is FunctionExpression) {
              e3.childEntities.forEach((element) {
                if (element is ExpressionFunctionBody) {
                  element.childEntities.forEach((x5) {
                    if (x5 is SetOrMapLiteral) {
                      x5.childEntities.forEach((x6) {
                        if (x6 is MethodInvocation) {
                          x6.childEntities.forEach((x7) {
                            if (x7 is ArgumentList) {
                              x7.childEntities.forEach((x8) {
                                print("---> " +
                                    x8.toString() +
                                    " ---- " +
                                    x8.runtimeType.toString());
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
          });
        }
      });
    }
  });
}

bool isTest(AstNode e) {
  return e is ExpressionStatement &&
      e.beginToken.type == TokenType.IDENTIFIER &&
      e.beginToken.toString() == "test";
}

void detectTestSmells(ExpressionStatement e) {
  detectCTL(e);
  detectPSF(e);
  detectSleep(e);
  testWithoutDescription(e);
  magicNumber(e);
}

void scan(AstNode n) {
  n.childEntities.forEach((element) {
    if (element is AstNode) {
      if (isTest(element)) {
        print("Achei um Teste...");
        print(element.toSource());
        detectTestSmells(element as ExpressionStatement);
      }
      scan(element);
    }
  });
}

void main() async {
  var ast = parseFile(
          path:
              '/home/tassio/Desenvolvimento/Dart/teste01/test/teste01_test.dart',
          featureSet: FeatureSet.latestLanguageVersion())
      .unit;

  // print(ast.toSource());

  AstNode astnode = ast.root;

  // print("---------------  Achei uma função...");

  scan(astnode);

  print("Foram encontrado " + testSmells.length.toString() + " Test Smells.");

  // astnode.childEntities.forEach((element) {
  //   print(element.toString() + "\n");
  // });

  // detectar01(astnode);
}

void detectar01(AstNode astnode) {
  astnode.childEntities.forEach((element) {
    // print(element.runtimeType);

    if (element is FunctionDeclaration) {
      print("---------------  Achei uma função...");

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
                        // detectCTL(e.toSource());
                        // detectPSF(e.toSource());
                        // detectSleep(e.toSource());
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
