import 'dart:ffi';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:teste01/TestSmell.dart';

class ConditionalTestLogic {
  String nome = "ConditionalTestLogic";

  static List<TestSmell> detect(ExpressionStatement e) {
    List<TestSmell> testSmells = List.empty(growable: true);
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
    return testSmells;
  }
}
