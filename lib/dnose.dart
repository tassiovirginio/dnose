import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/detectors/assertion_roulette_detector.dart';
import 'package:dnose/detectors/conditional_test_logic_detector.dart';
import 'package:dnose/detectors/duplicate_assert_detector.dart';
import 'package:dnose/detectors/empty_test_detector.dart';
import 'package:dnose/detectors/exception_handling_detector.dart';
import 'package:dnose/detectors/ignored_test_detector.dart';
import 'package:dnose/detectors/magic_number_detector.dart';
import 'package:dnose/detectors/print_statment_fixture_detector.dart';
import 'package:dnose/detectors/resource_optimism_detector.dart';
import 'package:dnose/detectors/sensitive_equality_detector.dart';
import 'package:dnose/detectors/sleepy_fixture_detector.dart';
import 'package:dnose/detectors/test_without_description_detector.dart';
import 'package:dnose/detectors/unknown_test_detector.dart';
import 'package:dnose/detectors/verbose_test_detector.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/metrics/cyclomatic_complexity_metric.dart';
import 'package:dnose/metrics/lines_of_code_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/git_utils.dart';
import 'package:git/git.dart';
import 'package:logging/logging.dart';

class DNose {
  static final Logger _logger = Logger('DNose');

  static int contProcessProject = 0;

  static final List<String> listTestSmellsNames = [
    ConditionalTestLogicDetector().testSmellName,
    PrintStatmentFixtureDetector().testSmellName,
    TestWithoutDescriptionDetector().testSmellName,
    MagicNumberDetector().testSmellName,
    SleepyFixtureDetector().testSmellName,
    DuplicateAssertDetector().testSmellName,
    ResourceOptimismDetector().testSmellName,
    AssertionRouletteDetector().testSmellName,
    VerboseTestDetector().testSmellName,
    EmptyTestDetector().testSmellName,
    UnknownTestDetector().testSmellName,
    ExceptionHandlingDetector().testSmellName,
    IgnoredTestDetector().testSmellName
  ];

  final Set<String> listTestNames = {"test","testWidgets","testWithGame","isarTest"};

  bool isTest(AstNode e) {
    return e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        (listTestNames.contains(e.beginToken.toString())); //Métodos de teste do Flutter
  }

  List<TestMetric> calculeTestMetrics(
      ExpressionStatement e, TestClass testClass, String testName) {
    List<TestMetric> testMetrics = List.empty(growable: true);

    List<AbstractMetric> metrics = [
      LinesOfCodeMetric(),
      CyclomaticComplexityMetric(),
    ];

    for (var m in metrics) {
      testMetrics.add(m.calculate(e, testClass, testName));
    }

    return testMetrics;
  }

  List<TestSmell> detectTestSmells(
      ExpressionStatement e, TestClass testClass, String testName) {
    List<TestSmell> testSmells = List.empty(growable: true);

    //se mudar de local essa lista a detecção fica lenta.
    List<AbstractDetector> detectors = [
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
      UnknownTestDetector(),
      ExceptionHandlingDetector(),
      IgnoredTestDetector(),
      SensitiveEqualityDetector()
    ];

    for (var d in detectors) {
      testSmells.addAll(d.detect(e, testClass, testName));
    }

    return testSmells;
  }

  (List<TestSmell>,List<TestMetric>) scan(TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    List<TestMetric> testMetrics = List.empty(growable: true);
    AstNode n = testClass.root;
    _logger.info("Scanning...");
    _logger.info("Path: ${testClass.path}");
    testSmells.addAll(_scan(n, testClass));
    testMetrics.addAll(_scanMetric(n, testClass));
    return (testSmells, testMetrics);
  }


  List<TestMetric> _scanMetric(AstNode n, TestClass testClass) {
    List<TestMetric> testMetrics = List.empty(growable: true);
    n.childEntities.whereType<AstNode>().forEach((element) {
      if (isTest(element)) {
        String testName = getTestName(element);
        _logger.info("Test Function Detect: $testName - ${element.toSource()}");
        testMetrics.addAll(calculeTestMetrics(
            element as ExpressionStatement, testClass, testName));
      }
      testMetrics.addAll(_scanMetric(element, testClass));
    });
    return testMetrics;
  }

  List<TestSmell> _scan(AstNode n, TestClass testClass) {
    List<TestSmell> testSmells = List.empty(growable: true);
    n.childEntities.whereType<AstNode>().forEach((element) {
      if (isTest(element)) {
        String testName = getTestName(element);
        _logger.info("Test Function Detect: $testName - ${element.toSource()}");
        testSmells.addAll(detectTestSmells(
            element as ExpressionStatement, testClass, testName));
      }
      testSmells.addAll(_scan(element, testClass));
    });
    return testSmells;
  }

  String getCodeTestByDescription(String path, String description) {
    TestClass testClass =
        TestClass(path: path, moduleAtual: "", projectName: "", commit: "");
    var root = testClass.root;
    List<String> code = _scan2(root, testClass, description);
    return code.first;
  }

  List<String> _scan2(AstNode n, TestClass testClass, String description) {
    description = description.replaceAll("'", "");
    List<String> testSmells = List.empty(growable: true);
    n.childEntities.whereType<AstNode>().forEach((element) {
      if (isTest(element)) {
        if (element.toSource().contains(description)) {
          testSmells.add(element.toSource());
        }
      }
      testSmells.addAll(_scan2(element, testClass, description));
    });
    return testSmells;
  }

  String getTestName(AstNode e) {
    String testName = "";
    if (e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        (e.beginToken.toString() == "test" ||
            e.beginToken.toString() == "testWidgets")) {
      e.childEntities.whereType<MethodInvocation>().forEach((element) {
        element.childEntities.whereType<ArgumentList>().forEach((element) {
          element.childEntities
              .whereType<SimpleStringLiteral>()
              .forEach((element) {
            testName = element.value;
          });
        });
      });
    }
    testName = testName.replaceAll("\"", "-");
    return testName;
  }


  mining(String pathProject) async {
    print("Minerando: $pathProject");
    final Map<String, Commit> mapa = await GitUtil.getListCommits(pathProject);

    mapa.forEach((key,value){
      print("$key -> $value");
    });

  }

}
