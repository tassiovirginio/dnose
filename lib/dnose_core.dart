import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/detectors/assertion_roulette_detector.dart';
import 'package:dnose/detectors/conditional_test_logic_detector.dart';
import 'package:dnose/detectors/constructor_initialization_detector.dart';
import 'package:dnose/detectors/default_test_detector.dart';
import 'package:dnose/detectors/dependent_test_detector.dart';
import 'package:dnose/detectors/duplicate_assert_detector.dart';
import 'package:dnose/detectors/eager_test_detector.dart';
import 'package:dnose/detectors/empty_test_detector.dart';
import 'package:dnose/detectors/exception_handling_detector.dart';
import 'package:dnose/detectors/expected_resolution_omission_detector.dart';
import 'package:dnose/detectors/ignored_test_detector.dart';
import 'package:dnose/detectors/lazy_test_detector.dart';
import 'package:dnose/detectors/magic_number_detector.dart';
import 'package:dnose/detectors/mystery_guest_detector.dart';
import 'package:dnose/detectors/redundant_assertion_detector.dart';
import 'package:dnose/detectors/residual_state_test_detector.dart';
import 'package:dnose/detectors/print_statment_fixture_detector.dart';
import 'package:dnose/detectors/resource_optimism_detector.dart';
import 'package:dnose/detectors/sensitive_equality_detector.dart';
import 'package:dnose/detectors/sleepy_fixture_detector.dart';
import 'package:dnose/detectors/test_without_description_detector.dart';
import 'package:dnose/detectors/unknown_test_detector.dart';
import 'package:dnose/detectors/verbose_test_detector.dart';
import 'package:dnose/detectors/general_fixture_detector.dart';
import 'package:dnose/detectors/widget_setup_detector.dart';
import 'package:dnose/metrics/abstract_metric.dart';
import 'package:dnose/metrics/cyclomatic_complexity_metric.dart';
import 'package:dnose/metrics/lines_of_code_metric.dart';
import 'package:dnose/metrics/logical_lines_of_code_metric.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_metric.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/git_utils.dart';
import 'package:git/git.dart';
import 'package:logging/logging.dart';

class DNoseCore {
  static final Logger _logger = Logger('DNose');

  static int contProcessProject = 0;

  static final List<String> listTestSmellsNames = [
    ConditionalTestLogicDetector().testSmellName,
    ConstructorInitializationDetector().testSmellName,
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
    IgnoredTestDetector().testSmellName,
    RedundantAssertionDetector().testSmellName,
    ExpectedResolutionOmissionDetector().testSmellName,
    ResidualStateTestDetector().testSmellName,
    EagerTestDetector().testSmellName,
    LazyTestDetector().testSmellName,
    WidgetSetupDetector().testSmellName,
    MysteryGuestDetector().testSmellName,
    DefaultTestDetector().testSmellName,
    SensitiveEqualityDetector().testSmellName,
    DependentTestDetector().testSmellName,
    GeneralFixtureDetector().testSmellName,
  ];

  final Set<String> listTestNames = {
    "test",
    "testWidgets",
    "testWithGame",
    "isarTest",
  };

  bool isTest(AstNode e) {
    return e is ExpressionStatement &&
        e.beginToken.type == TokenType.IDENTIFIER &&
        (listTestNames.contains(
          e.beginToken.toString(),
        )); //Métodos de teste do Flutter
  }

  /// Creates the list of detectors once, optionally filtered.
  List<AbstractDetector> _createDetectors([List<String>? selectedSmells]) {
    List<AbstractDetector> detectors = [
      ConditionalTestLogicDetector(),
      ConstructorInitializationDetector(),
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
      SensitiveEqualityDetector(),
      DefaultTestDetector(),
      ResidualStateTestDetector(),
      EagerTestDetector(),
      LazyTestDetector(),
      WidgetSetupDetector(),
      ExpectedResolutionOmissionDetector(),
      MysteryGuestDetector(),
      RedundantAssertionDetector(),
      DependentTestDetector(),
      GeneralFixtureDetector(),
    ];

    if (selectedSmells != null && selectedSmells.isNotEmpty) {
      detectors =
          detectors.where((d) {
            return selectedSmells.contains(
              d.testSmellName.replaceAll(' ', '_').toLowerCase(),
            );
          }).toList();
    }

    return detectors;
  }

  /// Creates the list of metrics once.
  List<AbstractMetric> _createMetrics() {
    return [
      LinesOfCodeMetric(),
      CyclomaticComplexityMetric(),
      LogicalLinesOfCodeMetric(),
    ];
  }

  List<TestMetric> calculeTestMetrics(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    List<TestMetric> testMetrics = List.empty(growable: true);

    List<AbstractMetric> metrics = [
      LinesOfCodeMetric(),
      CyclomaticComplexityMetric(),
      LogicalLinesOfCodeMetric(),
    ];

    for (var m in metrics) {
      testMetrics.add(m.calculate(e, testClass, testName));
    }

    return testMetrics;
  }

  List<TestSmell> detectTestSmells(
    ExpressionStatement e,
    TestClass testClass,
    String testName, [
    List<String>? selectedSmells,
  ]) {
    List<TestSmell> testSmells = List.empty(growable: true);

    List<AbstractDetector> detectors = _createDetectors(selectedSmells);

    for (var d in detectors) {
      testSmells.addAll(d.detect(e, testClass, testName));
    }

    return testSmells;
  }

  (List<TestSmell>, List<TestMetric>) scan(
    TestClass testClass, [
    List<String>? selectedSmells,
  ]) {
    List<TestSmell> testSmells = List.empty(growable: true);
    List<TestMetric> testMetrics = List.empty(growable: true);
    AstNode n = testClass.root;
    _logger.info("Scanning...");
    _logger.info("Path: ${testClass.path}");

    LazyTestDetector.reset();
    WidgetSetupDetector.reset();
    GeneralFixtureDetector.reset();

    // Reuse detector and metric instances for all tests in this file
    final detectors = _createDetectors(selectedSmells);
    final metrics = _createMetrics();

    // Single traversal: smells + metrics together
    _scanAll(n, testClass, detectors, metrics, testSmells, testMetrics);

    if (selectedSmells == null ||
        selectedSmells.isEmpty ||
        selectedSmells.contains('lazy_test')) {
      testSmells.addAll(LazyTestDetector.detectLazyTests());
    }

    if (selectedSmells == null ||
        selectedSmells.isEmpty ||
        selectedSmells.contains('widget_setup')) {
      testSmells.addAll(WidgetSetupDetector.detectWidgetSetup());
    }

    if (selectedSmells == null ||
        selectedSmells.isEmpty ||
        selectedSmells.contains('general_fixture')) {
      testSmells.addAll(GeneralFixtureDetector.detectGeneralFixtures());
    }

    return (testSmells, testMetrics);
  }

  /// Single-pass traversal: detects smells AND calculates metrics in one walk.
  void _scanAll(
    AstNode n,
    TestClass testClass,
    List<AbstractDetector> detectors,
    List<AbstractMetric> metrics,
    List<TestSmell> testSmells,
    List<TestMetric> testMetrics,
  ) {
    n.childEntities.whereType<AstNode>().forEach((element) {
      // Collect setUp variables for General Fixture detection
      if (element is ExpressionStatement &&
          element.beginToken.toString() == 'setUp') {
        final setupBody = _extractSetupBody(element);
        if (setupBody != null) {
          GeneralFixtureDetector.collectSetupData(setupBody, testClass);
        }
      }

      if (isTest(element)) {
        String testName = getTestName(element);
        _logger.info("Test Function Detect: $testName - ${element.toSource()}");
        final expr = element as ExpressionStatement;

        // Collect cross-test data
        LazyTestDetector.collectMethodCalls(expr, testClass, testName);
        WidgetSetupDetector.collectSetupPatterns(expr, testClass, testName);
        GeneralFixtureDetector.collectTestData(expr, testClass, testName);

        // Detect smells (reusing detector instances)
        for (var d in detectors) {
          testSmells.addAll(d.detect(expr, testClass, testName));
        }

        // Calculate metrics (reusing metric instances)
        for (var m in metrics) {
          testMetrics.add(m.calculate(expr, testClass, testName));
        }
      }
      _scanAll(element, testClass, detectors, metrics, testSmells, testMetrics);
    });
  }

  String getCodeTestByDescription(String path, String description) {
    TestClass testClass = TestClass(
      path: path,
      moduleAtual: "",
      projectName: "",
      commit: "",
    );
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
          element.childEntities.whereType<SimpleStringLiteral>().forEach((
            element,
          ) {
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

    mapa.forEach((key, value) {
      print("$key -> $value");
    });
  }

  /// Extracts the FunctionBody from a setUp(...) call, if present.
  FunctionBody? _extractSetupBody(ExpressionStatement element) {
    final methodInvocations = element.childEntities.whereType<MethodInvocation>();
    for (final invocation in methodInvocations) {
      if (invocation.methodName.name == 'setUp') {
        for (final arg in invocation.argumentList.arguments) {
          if (arg is FunctionExpression) {
            return arg.body;
          }
        }
      }
    }
    return null;
  }
}
