import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class DependentTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Dependent Test";

  // Variáveis globais encontradas no arquivo
  static final Set<String> _globalVariables = {};

  // Mapa: variável global -> Set de testes que a usam (leitura)
  static final Map<String, Set<String>> _globalVarUsage = {};

  // Mapa: variável global -> Set de testes que a ESCREVEM
  static final Map<String, Set<String>> _globalVarWrites = {};

  // Mapa: variável global -> foi inicializada em setUp?
  static final Set<String> _initializedInSetUp = {};

  // Flag para indicar se já processamos o arquivo inteiro
  static String? _currentFile;
  static bool _fileProcessed = false;

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

    // Se mudou de arquivo, reseta tudo
    final currentFile = testClass.root.toString();
    if (_currentFile != currentFile) {
      _reset();
      _currentFile = currentFile;
      _fileProcessed = false;
    }

    // Na primeira execução, processa o arquivo inteiro
    if (!_fileProcessed) {
      final compilationUnit = _findCompilationUnit(testClass.root);
      if (compilationUnit != null) {
        _scanEntireFile(compilationUnit);
      }
      _fileProcessed = true;
    }

    // Detecta uso e escrita de variáveis globais neste teste
    _detectInTest(e as AstNode, testName);

    // Verifica se há smells ao final
    _checkForSmells(e, testClass, testName);

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

  void _reset() {
    _globalVariables.clear();
    _globalVarUsage.clear();
    _globalVarWrites.clear();
    _initializedInSetUp.clear();
    testSmells = [];
  }

  void _scanEntireFile(CompilationUnit root) {
    for (var declaration in root.declarations) {
      if (declaration is TopLevelVariableDeclaration) {
        for (var variable in declaration.variables.variables) {
          final varName = variable.name.lexeme;
          if (!declaration.variables.isFinal &&
              !declaration.variables.isConst) {
            _globalVariables.add(varName);
            _globalVarUsage[varName] = {};
            _globalVarWrites[varName] = {};
          }
        }
      }
    }
    _findSetUpInMain(root);
  }

  void _findSetUpInMain(CompilationUnit root) {
    for (var declaration in root.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'main') {
        final body = declaration.functionExpression.body;
        if (body is BlockFunctionBody) {
          final finder = _SetUpFinder(_globalVariables, _initializedInSetUp);
          body.block.accept(finder);
        }
      }
    }
  }

  void _detectInTest(AstNode node, String testName) {
    final detector = _TestVarDetector(
      _globalVariables,
      _globalVarUsage,
      _globalVarWrites,
      testName,
    );
    node.accept(detector);
  }

  void _checkForSmells(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    _globalVariables.forEach((varName) {
      final testsWritingVar = _globalVarWrites[varName] ?? {};

      if (testsWritingVar.length >= 2 &&
          !_initializedInSetUp.contains(varName)) {
        final testList = testsWritingVar.toList();
        final testIndex = testList.indexOf(testName);

        if (testIndex > 0) {
          testSmells.add(
            TestSmell(
              name: testSmellName,
              testName: testName,
              path: testClass.path,
              projectName: testClass.projectName,
              moduleAtual: testClass.moduleAtual,
              commit: testClass.commit,
              code:
                  'Test depends on shared variable "$varName" modified by previous test(s): ${testList.sublist(0, testIndex).join(", ")}',
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
    });
  }

  @override
  String getDescription() {
    return '''
Dependent Test occurs when tests share mutable state without proper isolation.
This creates dependencies between tests, making them fragile and order-dependent.
Detection: A mutable global variable is written to by 2+ tests without being reset in setUp().
''';
  }

  @override
  String getExample() {
    return '''
// Dependent Test smell:
int counter = 0;

test('DT1: increments', () {
  counter++;
});

test('DT2: expects zero', () {
  expect(counter, 0); // Fails if DT1 runs first!
});

// Valid approach:
late int counter;

setUp(() {
  counter = 0; // Reset before each test
});

test('Valid: increments', () {
  counter++;
});

test('Valid: expects zero', () {
  expect(counter, 0); // Always passes
});
''';
  }
}

/// Visitor to find setUp calls and scan their bodies for variable initializations.
class _SetUpFinder extends RecursiveAstVisitor<void> {
  final Set<String> globalVariables;
  final Set<String> initializedInSetUp;

  _SetUpFinder(this.globalVariables, this.initializedInSetUp);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'setUp') {
      if (node.argumentList.arguments.isNotEmpty) {
        final arg = node.argumentList.arguments.first;
        if (arg is FunctionExpression) {
          final body = arg.body;
          if (body is BlockFunctionBody) {
            final assignFinder = _AssignmentFinder(
              globalVariables,
              initializedInSetUp,
            );
            body.block.accept(assignFinder);
          } else if (body is ExpressionFunctionBody) {
            final assignFinder = _AssignmentFinder(
              globalVariables,
              initializedInSetUp,
            );
            body.expression.accept(assignFinder);
          }
        }
      }
    }
    super.visitMethodInvocation(node);
  }
}

/// Visitor to find assignments to global variables.
class _AssignmentFinder extends RecursiveAstVisitor<void> {
  final Set<String> globalVariables;
  final Set<String> targetSet;

  _AssignmentFinder(this.globalVariables, this.targetSet);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.leftHandSide is SimpleIdentifier) {
      final varName = (node.leftHandSide as SimpleIdentifier).name;
      if (globalVariables.contains(varName)) {
        targetSet.add(varName);
      }
    }
    super.visitAssignmentExpression(node);
  }
}

/// Visitor to detect reads and writes to global variables in a test.
class _TestVarDetector extends RecursiveAstVisitor<void> {
  final Set<String> globalVariables;
  final Map<String, Set<String>> globalVarUsage;
  final Map<String, Set<String>> globalVarWrites;
  final String testName;

  _TestVarDetector(
    this.globalVariables,
    this.globalVarUsage,
    this.globalVarWrites,
    this.testName,
  );

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (node.leftHandSide is SimpleIdentifier) {
      final varName = (node.leftHandSide as SimpleIdentifier).name;
      if (globalVariables.contains(varName)) {
        globalVarWrites[varName]?.add(testName);
      }
    }
    super.visitAssignmentExpression(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!_isLeftHandSideOfAssignment(node)) {
      final varName = node.name;
      if (globalVariables.contains(varName)) {
        globalVarUsage[varName]?.add(testName);
      }
    }
    super.visitSimpleIdentifier(node);
  }

  bool _isLeftHandSideOfAssignment(SimpleIdentifier identifier) {
    final parent = identifier.parent;
    if (parent is AssignmentExpression) {
      return parent.leftHandSide == identifier;
    }
    return false;
  }
}
