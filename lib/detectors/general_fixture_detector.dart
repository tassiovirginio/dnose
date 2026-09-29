import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

/// Detects the General Fixture test smell.
///
/// Occurs when a setUp() method initializes variables that are not all
/// accessed by every test method in the same scope. If a test does not use
/// at least one variable assigned in setUp(), it is flagged.
class GeneralFixtureDetector extends AbstractDetector {
  @override
  get testSmellName => "General Fixture";

  // Per-file state: maps filePath -> list of setUp variable names
  static final Map<String, Set<String>> _setupVars = {};

  // Per-file state: maps filePath -> list of (testName, usedVars, expression, testClass)
  static final Map<String, List<_TestInfo>> _testInfos = {};

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    // Detection is deferred to detectGeneralFixtures()
    return [];
  }

  static void reset() {
    _setupVars.clear();
    _testInfos.clear();
  }

  /// Called for every setUp(...) call found during the AST walk.
  static void collectSetupData(
    FunctionBody setupBody,
    TestClass testClass,
  ) {
    final filePath = testClass.path;
    _setupVars.putIfAbsent(filePath, () => {});

    final collector = _AssignmentCollector();
    setupBody.accept(collector);
    _setupVars[filePath]!.addAll(collector.assignedVars);
  }

  /// Called for every test(...) expression during the AST walk.
  static void collectTestData(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final filePath = testClass.path;
    _testInfos.putIfAbsent(filePath, () => []);

    final collector = _IdentifierCollector();
    e.accept(collector);

    _testInfos[filePath]!.add(
      _TestInfo(
        testName: testName,
        usedIdentifiers: collector.identifiers,
        expression: e,
        testClass: testClass,
      ),
    );
  }

  /// After all tests and setUp data have been collected, emit smells.
  static List<TestSmell> detectGeneralFixtures() {
    final smells = <TestSmell>[];

    for (final fileEntry in _setupVars.entries) {
      final filePath = fileEntry.key;
      final setupVariables = fileEntry.value;

      if (setupVariables.isEmpty) continue;

      final tests = _testInfos[filePath];
      if (tests == null || tests.isEmpty) continue;

      for (final info in tests) {
        // Find which setUp variables this test does NOT use
        final unused = setupVariables.difference(info.usedIdentifiers);

        if (unused.isNotEmpty) {
          smells.add(
            TestSmell(
              name: "General Fixture",
              testName: info.testName,
              path: info.testClass.path,
              projectName: info.testClass.projectName,
              moduleAtual: info.testClass.moduleAtual,
              commit: info.testClass.commit,
              code:
                  'Test "${info.testName}" does not use setUp variable(s): ${unused.join(", ")}',
              codeMD5: Util.md5(info.expression.toSource()),
              start: info.testClass.lineNumber(info.expression.offset),
              end: info.testClass.lineNumber(info.expression.end),
              collumnStart: info.testClass.columnNumber(
                info.expression.offset,
              ),
              collumnEnd: info.testClass.columnNumber(info.expression.end),
              codeTest: info.expression.toSource(),
              codeTestMD5: Util.md5(info.expression.toSource()),
              startTest: info.testClass.lineNumber(info.expression.offset),
              endTest: info.testClass.lineNumber(info.expression.end),
              offset: info.expression.offset,
              endOffset: info.expression.end,
            ),
          );
        }
      }
    }

    return smells;
  }

  @override
  String getDescription() {
    return '''
General Fixture occurs when the setUp() method of a test class initializes fields 
or variables that are not all accessed by every test method in the same scope. 
This means the fixture is too general: unnecessary setup work is performed for 
tests that do not need all initialized resources.

Detection: If a test method does not use at least one variable assigned in setUp(), 
the test is flagged as having a General Fixture smell.
''';
  }

  @override
  String getExample() {
    return '''
// General Fixture smell:
setUp(() {
  userService = UserService();   // used by all tests
  emailService = EmailService(); // NOT used by testLogin
  database = Database();         // used by all tests
});

test('testLogin', () {
  // Only uses userService and database — emailService is unused here!
  expect(userService.login('admin', 'secret', database), isTrue);
});

// Correct approach: split into focused setUp groups or use local variables
''';
  }
}

// ---------------------------------------------------------------------------
// Internal data holder
// ---------------------------------------------------------------------------

class _TestInfo {
  final String testName;
  final Set<String> usedIdentifiers;
  final ExpressionStatement expression;
  final TestClass testClass;

  _TestInfo({
    required this.testName,
    required this.usedIdentifiers,
    required this.expression,
    required this.testClass,
  });
}

// ---------------------------------------------------------------------------
// Visitor: collect variable names assigned in setUp body
// ---------------------------------------------------------------------------

class _AssignmentCollector extends RecursiveAstVisitor<void> {
  final Set<String> assignedVars = {};

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final lhs = node.leftHandSide;
    if (lhs is SimpleIdentifier) {
      assignedVars.add(lhs.name);
    } else if (lhs is PropertyAccess) {
      // e.g. this.field = ...
      final prop = lhs.propertyName.name;
      assignedVars.add(prop);
    }
    super.visitAssignmentExpression(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    // also catch `var x = ...` inside setUp
    if (node.initializer != null) {
      assignedVars.add(node.name.lexeme);
    }
    super.visitVariableDeclaration(node);
  }
}

// ---------------------------------------------------------------------------
// Visitor: collect all simple identifiers referenced in a test body
// ---------------------------------------------------------------------------

class _IdentifierCollector extends RecursiveAstVisitor<void> {
  final Set<String> identifiers = {};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    identifiers.add(node.name);
    super.visitSimpleIdentifier(node);
  }
}
