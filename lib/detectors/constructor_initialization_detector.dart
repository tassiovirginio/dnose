import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ConstructorInitializationDetector extends AbstractDetector {
  @override
  get testSmellName => "Constructor Initialization";

  // Armazena classes com construtores e suas inicializações
  static final Map<String, List<String>> _constructorInitializations = {};
  static String? _currentFile;
  static bool _fileScanned = false;

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    this.testSmells = [];
    this.testClass = testClass;
    this.testName = testName;
    this.codeTest = e.toSource();
    this.startTest = testClass.lineNumber(e.offset);
    this.endTest = testClass.lineNumber(e.end);

    final currentFile = testClass.root.toString();
    if (_currentFile != currentFile) {
      _constructorInitializations.clear();
      _currentFile = currentFile;
      _fileScanned = false;
    }

    if (!_fileScanned) {
      final compilationUnit = _findCompilationUnit(testClass.root);
      if (compilationUnit != null) {
        _scanEntireFile(compilationUnit);
      }
      _fileScanned = true;
    }

    _checkForSmellInTest(e, testClass, testName);

    return testSmells;
  }

  CompilationUnit? _findCompilationUnit(AstNode node) {
    AstNode? current = node;
    while (current != null) {
      if (current is CompilationUnit) return current;
      current = current.parent;
    }
    return null;
  }

  void _scanEntireFile(CompilationUnit root) {
    final scanner = _ClassScanner(_constructorInitializations);
    root.accept(scanner);
  }

  void _checkForSmellInTest(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final className = _findEnclosingTestClass(e);

    if (className != null &&
        _constructorInitializations.containsKey(className)) {
      final fields = _constructorInitializations[className]!;

      testSmells.add(
        TestSmell(
          name: testSmellName,
          testName: testName,
          path: testClass.path,
          projectName: testClass.projectName,
          moduleAtual: testClass.moduleAtual,
          commit: testClass.commit,
          code:
              'Test class "$className" initializes fixtures in constructor: ${fields.join(", ")}',
          codeMD5: Util.md5(e.toSource()),
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          codeTest: codeTest,
          codeTestMD5: Util.md5(codeTest),
          startTest: startTest,
          endTest: endTest,
          offset: e.offset,
          endOffset: e.end,
        ),
      );
    }
  }

  String? _findEnclosingTestClass(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        final className = current.name.lexeme;
        if (className.endsWith('Test')) return className;
      }
      current = current.parent;
    }
    return null;
  }

  @override
  String getDescription() {
    return '''
Constructor Initialization occurs when a test class defines an explicit constructor to initialize test fixtures or dependencies, instead of using the testing framework's lifecycle methods (such as setUp()).

Ideally, a test suite should not define a constructor at all. Initialization logic must be placed in setup methods that are executed before each test case. When initialization is performed inside a constructor, it bypasses the intended test lifecycle, leading to reduced clarity, improper state management, and potential test interdependence.

This smell commonly arises when developers are unaware of the purpose of the setUp() method or attempt to replicate production-style object construction within test classes.
''';
  }

  @override
  String getExample() {
    return '''
// Constructor Initialization smell:
class CalculatorTest {
  late Calculator calculator;

  CalculatorTest() {
    calculator = Calculator(); // SMELL: initialization in constructor
  }

  void run() {
    test('adds two numbers', () {
      expect(calculator.add(2, 3), 5);
    });
  }
}

// Correct approach:
void main() {
  late Calculator calculator;

  setUp(() {
    calculator = Calculator(); // Proper initialization
  });

  test('adds two numbers', () {
    expect(calculator.add(2, 3), 5);
  });
}
''';
  }
}

/// Internal visitor to scan class declarations for constructor initializations.
class _ClassScanner extends RecursiveAstVisitor<void> {
  final Map<String, List<String>> constructorInitializations;

  _ClassScanner(this.constructorInitializations);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.lexeme;
    if (!className.endsWith('Test')) return;

    for (var member in node.members) {
      if (member is ConstructorDeclaration) {
        final initializations = _extractInitializations(member);
        if (initializations.isNotEmpty) {
          constructorInitializations[className] = initializations;
        }
        break;
      }
    }
    // Don't call super — we don't need to recurse into class bodies
  }

  List<String> _extractInitializations(ConstructorDeclaration constructor) {
    final initializations = <String>[];

    for (var initializer in constructor.initializers) {
      if (initializer is ConstructorFieldInitializer) {
        initializations.add(initializer.fieldName.name);
      }
    }

    final body = constructor.body;
    if (body is BlockFunctionBody) {
      final finder = _ConstructorAssignmentFinder(initializations);
      body.block.accept(finder);
    }

    return initializations;
  }
}

/// Internal visitor to find assignments in constructor bodies.
class _ConstructorAssignmentFinder extends RecursiveAstVisitor<void> {
  final List<String> initializations;

  _ConstructorAssignmentFinder(this.initializations);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final leftSide = node.leftHandSide;
    if (leftSide is PropertyAccess && leftSide.toString().startsWith('this.')) {
      final fieldName = leftSide.toString().substring(5);
      initializations.add(fieldName);
    } else if (leftSide is SimpleIdentifier) {
      initializations.add(leftSide.name);
    }
    super.visitAssignmentExpression(node);
  }
}
