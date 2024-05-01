// import 'dart:ffi';
// import 'dart:io';

// import 'package:analyzer/dart/analysis/utilities.dart';
// import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:teste01/detectors/AbstractDetectorTestSmell.dart';
import 'package:teste01/detectors/TestClass.dart';
import 'package:teste01/detectors/TestSmell.dart';
import 'package:teste01/detectors/DetectorConditionalTestLogic.dart';
import 'package:teste01/detectors/DetectorPrintStatmentFixture.dart';
import 'package:teste01/detectors/DetectorSleepyFixture.dart';
import 'package:teste01/detectors/DetectorTestWithoutDescription.dart';
import 'package:teste01/detectors/DetectorMagicNumber.dart';
import 'package:teste01/detectors/DetectorDuplicateAssert.dart';
import 'package:teste01/detectors/DetectorResourceOptimism.dart';

class DNose {
  bool isTest(AstNode e) {
    return e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        e.beginToken.toString() == "test";
  }

  List<TestSmell> detectTestSmells(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    List<AbstractDetectorTestSmell> detectors = List.empty(growable: true);

    detectors.add(DetectorConditionalTestLogic());
    detectors.add(DetectorPrintStatmentFixture());
    detectors.add(DetectorTestWithoutDescription());
    detectors.add(DetectorMagicNumber());
    detectors.add(DetectorSleepyFixture());
    detectors.add(DetectorDuplicateAssert());
    detectors.add(DetectorResourceOptimism());

    detectors.forEach((d) => testSmells.addAll(d.detect(e, testClass)));

    return testSmells;
  }

  List<TestSmell> scan(TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);

    AstNode n = testClass.root as AstNode;

    print("Scanning...");
    print("Path: " + testClass.path);
    // print(testClass.ast?.lineInfo.lineCount);
    // print(n.offset);

    testSmells.addAll(_scan(n, testClass));

    return testSmells;
  }

  List<TestSmell> _scan(AstNode n, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    n.childEntities.forEach((element) {
      if (element is AstNode) {
        if (isTest(element)) {
          print("Achei um Teste...");
          // Level.INFO("Achei um Teste...");
          testSmells.addAll(
              detectTestSmells(element as ExpressionStatement, testClass));
        }
        testSmells.addAll(_scan(element, testClass));
      }
    });
    return testSmells;
  }
}
