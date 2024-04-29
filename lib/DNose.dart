// import 'dart:ffi';
// import 'dart:io';

// import 'package:analyzer/dart/analysis/utilities.dart';
// import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:teste01/detectors/TestClass.dart';
import 'package:teste01/detectors/TestSmell.dart';
import 'package:teste01/detectors/DetectorConditionalTestLogic.dart';
import 'package:teste01/detectors/DetectorPrintStatmentFixture.dart';
import 'package:teste01/detectors/DetectorSleepyFixture.dart';
import 'package:teste01/detectors/DetectorTestWithoutDescription.dart';
import 'package:teste01/detectors/DetectorMagicNumber.dart';

class DNose {
  bool isTest(AstNode e) {
    return e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        e.beginToken.toString() == "test";
  }

  List<TestSmell> detectTestSmells(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);

    var detectorConditionalTestLogic = DetectorConditionalTestLogic();
    var detectorPrintStatmentFixture = DetectorPrintStatmentFixture();
    var detectorTestWithoutDescription = DetectorTestWithoutDescription();
    var detectorMagicNumber = DetectorMagicNumber();
    var detectorSleepyFixture = DetectorSleepyFixture();

    testSmells.addAll(detectorConditionalTestLogic.detect(e, testClass));
    testSmells.addAll(detectorPrintStatmentFixture.detect(e, testClass));
    testSmells.addAll(detectorTestWithoutDescription.detect(e, testClass));
    testSmells.addAll(detectorMagicNumber.detect(e, testClass));
    testSmells.addAll(detectorSleepyFixture.detect(e, testClass));

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
          // print(element.offset);
          // print(element.end);
          // print(element.length);
          // print(element.toSource());
          // print(element.toString());

          testSmells.addAll(
              detectTestSmells(element as ExpressionStatement, testClass));
        }
        testSmells.addAll(_scan(element, testClass));
      }
    });
    return testSmells;
  }

  void main() async {
    TestClass testClass = TestClass(
        '/home/tassio/Desenvolvimento/Dart/teste01/test/teste01_test.dart');

    // var ast = parseFile(
    //         path: testClass.path, featureSet: FeatureSet.latestLanguageVersion())
    //     .unit;

    // AstNode astNodeFile = ast.root;

    // print("start...");
    // print(ast.lineInfo.lineCount);
    // print(astNodeFile.offset);

    List<TestSmell> testSmells = scan(testClass);

    print("Foram encontrado " + testSmells.length.toString() + " Test Smells.");
  }
  
}
