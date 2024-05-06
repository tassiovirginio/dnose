import 'package:logging/logging.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dnose/detectors/AbstractDetectorTestSmell.dart';
import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:dnose/detectors/DetectorConditionalTestLogic.dart';
import 'package:dnose/detectors/DetectorPrintStatmentFixture.dart';
import 'package:dnose/detectors/DetectorSleepyFixture.dart';
import 'package:dnose/detectors/DetectorTestWithoutDescription.dart';
import 'package:dnose/detectors/DetectorMagicNumber.dart';
import 'package:dnose/detectors/DetectorDuplicateAssert.dart';
import 'package:dnose/detectors/DetectorResourceOptimism.dart';

class DNose {
  static final Logger _logger = Logger('DNose');
  static final String TESTE = "DNOSE";

  bool isTest(AstNode e) {
    return e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        (e.beginToken.toString() == "test" ||
            e.beginToken.toString() == "testWidgets"); //Métodos de teste do Flutter
  }

  List<TestSmell> detectTestSmells(ExpressionStatement e, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    List<AbstractDetectorTestSmell> detectors = List.empty(growable: true);

    detectors.addAll([
      DetectorConditionalTestLogic(),
      DetectorPrintStatmentFixture(),
      DetectorTestWithoutDescription(),
      DetectorMagicNumber(),
      DetectorSleepyFixture(),
      DetectorDuplicateAssert(),
      DetectorResourceOptimism()
    ]);

    detectors.forEach((d) => testSmells.addAll(d.detect(e, testClass)));

    return testSmells;
  }

  List<TestSmell> scan(TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    AstNode n = testClass.root as AstNode;
    _logger.info("Scanning...");
    _logger.info("Path: " + testClass.path);
    testSmells.addAll(_scan(n, testClass));
    return testSmells;
  }

  List<TestSmell> _scan(AstNode n, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    n.childEntities.forEach((element) {
      if (element is AstNode) {
        if (isTest(element)) {
          _logger.info("Test Detect: " + element.toSource());
          testSmells.addAll(
              detectTestSmells(element as ExpressionStatement, testClass));
        }
        testSmells.addAll(_scan(element, testClass));
      }
    });
    return testSmells;
  }
}
