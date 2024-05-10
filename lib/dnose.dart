import 'package:logging/logging.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/detectors/conditional_test_logic_detector.dart';
import 'package:dnose/detectors/print_statment_fixture_detector.dart';
import 'package:dnose/detectors/sleepy_fixture_detector.dart';
import 'package:dnose/detectors/test_without_description_detector.dart';
import 'package:dnose/detectors/magic_number_detector.dart';
import 'package:dnose/detectors/duplicate_assert_detector.dart';
import 'package:dnose/detectors/resource_optimism_detector.dart';
import 'package:dnose/detectors/assertion_roulette_detector.dart';
import 'package:dnose/detectors/verbose_test_detector.dart';
import 'package:dnose/detectors/empty_test_detector.dart';
import 'package:dnose/detectors/unknown_test_detector.dart';

class DNose {
  static final Logger _LOGGER = Logger('DNose');

  bool isTest(AstNode e) {
    return e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        (e.beginToken.toString() == "test" || //Métodos de teste normal
            e.beginToken.toString() ==
                "testWidgets"); //Métodos de teste do Flutter
  }

  List<TestSmell> detectTestSmells(
      ExpressionStatement e, TestClass testClass, String testName) {
    List<TestSmell> testSmells = List.empty(growable: true);
    List<AbstractDetector> detectors = List.empty(growable: true);

    detectors.addAll([
      ConditionalTestLogicDetector(),
      PrintStatmentFixtureDetector(),
      TestWithoutDescriptionDetector(),
      MagicNumberDetector(),
      SleepyFixtureDetector(),
      DuplicateAssertDetector(),
      ResourceOptimismDetector(),
      AssertionRouletteDetector(),
      VerboseTestDetector(),
      EmptyTestDetector(),
      UnknownTestDetector()
    ]);

    detectors
        .forEach((d) => testSmells.addAll(d.detect(e, testClass, testName)));

    return testSmells;
  }

  List<TestSmell> scan(TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    AstNode n = testClass.root;
    _LOGGER.info("Scanning...");
    _LOGGER.info("Path: ${testClass.path}");
    testSmells.addAll(_scan(n, testClass));
    return testSmells;
  }

  List<TestSmell> _scan(AstNode n, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    n.childEntities.forEach((element) {
      if (element is AstNode) {
        if (isTest(element)) {
          String testName = getTestName(element);
          _LOGGER.info(
              "Test Function Detect: $testName - ${element.toSource()}");
          testSmells.addAll(detectTestSmells(
              element as ExpressionStatement, testClass, testName));
        }
        testSmells.addAll(_scan(element, testClass));
      }
    });
    return testSmells;
  }

  String getTestName(AstNode e) {
    String testName = "";
    if (e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        (e.beginToken.toString() == "test" ||
            e.beginToken.toString() == "testWidgets")) {
      e.childEntities.forEach((element) {
        if (element is MethodInvocation) {
          element.childEntities.forEach((element) {
            if (element is ArgumentList) {
              element.childEntities.forEach((element) {
                if (element is SimpleStringLiteral) {
                  testName = element.value;
                }
              });
            }
          });
        }
      });
    }
    return testName;
  }
}
