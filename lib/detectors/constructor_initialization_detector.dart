import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ConstructorInitializationDetector implements AbstractDetector {
  @override
  get testSmellName => "Constructor Initialization";

  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  // Armazena classes com construtores e suas inicializações
  static final Map<String, List<String>> _constructorInitializations = {};
  static String? _currentFile;
  static bool _fileScanned = false;

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {

    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);

    final currentFile = testClass.root.toString();
    if (_currentFile != currentFile) {
      _constructorInitializations.clear();
      testSmells.clear();
      _currentFile = currentFile;
      _fileScanned = false;
    }

    // Escaneia o arquivo uma vez
    if (!_fileScanned) {
      final compilationUnit = _findCompilationUnit(testClass.root);
      if (compilationUnit != null) {
        _scanEntireFile(compilationUnit);
      }
      _fileScanned = true;
    }

    // Agora verifica se ESTE teste específico está dentro de uma classe com construtor
    _checkForSmellInTest(e, testClass, testName);

    return testSmells;
  }

  CompilationUnit? _findCompilationUnit(AstNode node) {
    AstNode? current = node;
    while (current != null) {
      if (current is CompilationUnit) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  void _scanEntireFile(CompilationUnit root) {
    for (var declaration in root.declarations) {
      if (declaration is ClassDeclaration) {
        _analyzeClass(declaration);
      }
    }
  }

  void _analyzeClass(ClassDeclaration classDecl) {
    final className = classDecl.name.lexeme;

    // Verifica se é uma classe de teste (nome termina com "Test")
    if (!className.endsWith('Test')) return;

    // Procura por construtores
    for (var member in classDecl.members) {
      if (member is ConstructorDeclaration) {
        final initializations = _extractInitializations(member);
        if (initializations.isNotEmpty) {
          _constructorInitializations[className] = initializations;
        }
        break;
      }
    }
  }

  List<String> _extractInitializations(ConstructorDeclaration constructor) {
    final initializations = <String>[];

    // Verifica inicializadores no construtor (this.field = value)
    for (var initializer in constructor.initializers) {
      if (initializer is ConstructorFieldInitializer) {
        initializations.add(initializer.fieldName.name);
      }
    }

    // Verifica corpo do construtor
    final body = constructor.body;
    if (body is BlockFunctionBody) {
      _findAssignmentsInBlock(body.block, initializations);
    }

    return initializations;
  }

  void _findAssignmentsInBlock(Block block, List<String> initializations) {
    for (var statement in block.statements) {
      if (statement is ExpressionStatement) {
        final expression = statement.expression;
        if (expression is AssignmentExpression) {
          final leftSide = expression.leftHandSide;
          
          if (leftSide is PropertyAccess && leftSide.toString().startsWith('this.')) {
            final fieldName = leftSide.toString().substring(5);
            initializations.add(fieldName);
          } else if (leftSide is SimpleIdentifier) {
            // Também pega assignments diretos como: calculator = Calculator();
            initializations.add(leftSide.name);
          }
        }
      }
    }
  }

  void _checkForSmellInTest(ExpressionStatement e, TestClass testClass, String testName) {
    // Encontra a classe que contém este teste
    final className = _findEnclosingTestClass(e);
    
    if (className != null && _constructorInitializations.containsKey(className)) {
      final fields = _constructorInitializations[className]!;
      
      // Reporta um smell para ESTE teste específico
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: 'Test class "$className" initializes fixtures in constructor: ${fields.join(", ")}',
          codeMD5: Util.md5(e.toSource()),
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          codeTest: codeTest,
          codeTestMD5: Util.md5(codeTest!),
          startTest: startTest,
          endTest: endTest,
          offset: e.offset,
          endOffset: e.end));
    }
  }

  String? _findEnclosingTestClass(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        final className = current.name.lexeme;
        if (className.endsWith('Test')) {
          return className;
        }
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