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

    // Usa o PATH do arquivo como chave de identidade (mais confiável que root.toString())
    final currentFile = testClass.path;
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
    // Escaneia TODAS as classes do arquivo (não só as que terminam em "Test")
    final scanner = _ClassScanner(_constructorInitializations);
    root.accept(scanner);
  }

  void _checkForSmellInTest(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    if (_constructorInitializations.isEmpty) return;

    String? detectedClass;
    List<String>? detectedFields;

    // Padrão 1 (clássico): test() está DENTRO de uma classe com CI
    final enclosingClass = _findEnclosingClass(e);
    if (enclosingClass != null &&
        _constructorInitializations.containsKey(enclosingClass)) {
      detectedClass = enclosingClass;
      detectedFields = _constructorInitializations[enclosingClass];
    }

    // Padrão 2 (moderno): alguma classe com CI é instanciada DENTRO do test()
    if (detectedClass == null) {
      final instantiatedClass = _findInstantiatedCIClass(e);
      if (instantiatedClass != null) {
        detectedClass = instantiatedClass;
        detectedFields = _constructorInitializations[instantiatedClass];
      }
    }

    if (detectedClass != null && detectedFields != null) {
      testSmells.add(
        TestSmell(
          name: testSmellName,
          testName: testName,
          path: testClass.path,
          projectName: testClass.projectName,
          moduleAtual: testClass.moduleAtual,
          commit: testClass.commit,
          code:
              'Class "$detectedClass" initializes fixtures in constructor: ${detectedFields.join(", ")}',
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

  /// Padrão 1: caminha para cima no AST desde o test() até encontrar uma
  /// ClassDeclaration que contenha o nó (qualquer nome de classe).
  String? _findEnclosingClass(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current.name.lexeme;
      }
      current = current.parent;
    }
    return null;
  }

  /// Padrão 2: procura instanciações de classes com CI dentro do corpo do test().
  /// Ex: `final h = MyHelper()` dentro do test() → retorna "MyHelper".
  String? _findInstantiatedCIClass(ExpressionStatement e) {
    final finder = _InstantiationFinder(
      _constructorInitializations.keys.toSet(),
    );
    e.accept(finder);
    return finder.foundClass;
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

// ─────────────────────────────────────────────────────────────────────────────
// Visitors internos
// ─────────────────────────────────────────────────────────────────────────────

/// Escaneia TODAS as classes do arquivo (qualquer nome) e coleta as que têm
/// construtores com inicializações de campos.
class _ClassScanner extends RecursiveAstVisitor<void> {
  final Map<String, List<String>> constructorInitializations;

  _ClassScanner(this.constructorInitializations);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.lexeme;

    for (var member in node.members) {
      if (member is ConstructorDeclaration) {
        final initializations = _extractInitializations(member);
        if (initializations.isNotEmpty) {
          constructorInitializations[className] = initializations;
        }
        break;
      }
    }
    // Não recursa dentro de classes — classes aninhadas são raras em Dart
  }

  List<String> _extractInitializations(ConstructorDeclaration constructor) {
    final initializations = <String>[];

    // Inicializações via lista de inicializadores: MyClass() : field = value;
    for (var initializer in constructor.initializers) {
      if (initializer is ConstructorFieldInitializer) {
        initializations.add(initializer.fieldName.name);
      }
    }

    // Inicializações via atribuição no corpo: this.field = value; ou field = value;
    final body = constructor.body;
    if (body is BlockFunctionBody) {
      final finder = _ConstructorAssignmentFinder(initializations);
      body.block.accept(finder);
    }

    return initializations;
  }
}

/// Encontra atribuições no corpo do construtor.
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

/// Procura instanciações (`ClassName()`) de classes que têm CI,
/// dentro do corpo de um test().
class _InstantiationFinder extends RecursiveAstVisitor<void> {
  final Set<String> ciClassNames;
  String? foundClass;

  _InstantiationFinder(this.ciClassNames);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    if (ciClassNames.contains(typeName) && foundClass == null) {
      foundClass = typeName;
    }
    super.visitInstanceCreationExpression(node);
  }
}
