import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class DependentTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Dependent Test";

  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

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
      ExpressionStatement e, TestClass testClass, String testName) {
    
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);

    // Se mudou de arquivo, reseta tudo
    final currentFile = testClass.root.toString();
    if (_currentFile != currentFile) {
      _reset();
      _currentFile = currentFile;
      _fileProcessed = false;
    }

    // Na primeira execução, processa o arquivo inteiro
    if (!_fileProcessed) {
      // Encontra o CompilationUnit navegando até o topo
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

  // Encontra o CompilationUnit a partir de qualquer nó
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

  void _reset() {
    _globalVariables.clear();
    _globalVarUsage.clear();
    _globalVarWrites.clear(); // Limpa o novo mapa
    _initializedInSetUp.clear();
    testSmells.clear();
  }

  // Varre o arquivo inteiro para encontrar variáveis globais
  void _scanEntireFile(CompilationUnit root) {
    for (var declaration in root.declarations) {
      // Detecta variáveis top-level
      if (declaration is TopLevelVariableDeclaration) {
        for (var variable in declaration.variables.variables) {
          final varName = variable.name.lexeme;
          
          // Só considera se não for final/const
          if (!declaration.variables.isFinal && 
              !declaration.variables.isConst) {
            _globalVariables.add(varName);
            _globalVarUsage[varName] = {};
            _globalVarWrites[varName] = {}; // Inicializa o novo mapa
          }
        }
      }
    }
    
    // Procura setUp dentro de main()
    _findSetUpInMain(root);
  }

  // Procura setUp dentro da função main
  void _findSetUpInMain(CompilationUnit root) {
    for (var declaration in root.declarations) {
      if (declaration is FunctionDeclaration && 
          declaration.name.lexeme == 'main') {
        final body = declaration.functionExpression.body;
        if (body is BlockFunctionBody) {
          _scanForSetUpCall(body.block);
        }
      }
    }
  }

  // Varre o bloco procurando por chamadas setUp()
  void _scanForSetUpCall(AstNode node) {
    if (node is ExpressionStatement && 
        node.expression is MethodInvocation) {
      final invocation = node.expression as MethodInvocation;
      if (invocation.methodName.name == 'setUp') {
        // Pega o closure passado para setUp
        if (invocation.argumentList.arguments.isNotEmpty) {
          final arg = invocation.argumentList.arguments.first;
          if (arg is FunctionExpression) {
            _scanSetUpForInitialization(arg);
          }
        }
      }
    }

    node.childEntities
        .whereType<AstNode>()
        .forEach((child) => _scanForSetUpCall(child));
  }

  // Varre setUp() para ver quais variáveis são reinicializadas
  void _scanSetUpForInitialization(FunctionExpression setUp) {
    final body = setUp.body;
    if (body is BlockFunctionBody) {
      _findAssignments(body.block, _initializedInSetUp);
    } else if (body is ExpressionFunctionBody) {
      _findAssignments(body.expression, _initializedInSetUp);
    }
  }

  // Encontra atribuições a variáveis
  void _findAssignments(AstNode node, Set<String> targetSet) {
    if (node is AssignmentExpression) {
      if (node.leftHandSide is SimpleIdentifier) {
        final varName = (node.leftHandSide as SimpleIdentifier).name;
        if (_globalVariables.contains(varName)) {
            targetSet.add(varName);
        }
      }
    }

    node.childEntities
        .whereType<AstNode>()
        .forEach((child) => _findAssignments(child, targetSet));
  }

  // Detecta uso e escrita de variáveis globais dentro de um teste
  void _detectInTest(AstNode node, String testName) {
    // Detecta ESCRITA em variáveis globais
    if (node is AssignmentExpression && node.leftHandSide is SimpleIdentifier) {
        final varName = (node.leftHandSide as SimpleIdentifier).name;
        if (_globalVariables.contains(varName)) {
            _globalVarWrites[varName]?.add(testName);
        }
    }

    // Detecta LEITURA de variáveis globais
    // Evita contar o lado esquerdo de assignments como leitura
    if (node is SimpleIdentifier && !_isLeftHandSideOfAssignment(node)) {
      final varName = node.name;
      if (_globalVariables.contains(varName)) {
        _globalVarUsage[varName]?.add(testName);
      }
    }

    node.childEntities
        .whereType<AstNode>()
        .forEach((child) => _detectInTest(child, testName));
  }

  // Verifica se o identificador é o lado esquerdo de uma atribuição
  bool _isLeftHandSideOfAssignment(SimpleIdentifier identifier) {
    final parent = identifier.parent;
    if (parent is AssignmentExpression) {
      return parent.leftHandSide == identifier;
    }
    return false;
  }

  // Verifica se há dependent test smells
  void _checkForSmells(ExpressionStatement e, TestClass testClass, String testName) {
    // Para cada variável global
    _globalVariables.forEach((varName) {
      final testsWritingVar = _globalVarWrites[varName] ?? {};
      
      // SMELL: Se a variável é ESCRITA em 2+ testes E não é resetada em setUp
      if (testsWritingVar.length >= 2 && 
          !_initializedInSetUp.contains(varName)) {
        
        // Converte para lista para verificar ordem
        final testList = testsWritingVar.toList();
        final testIndex = testList.indexOf(testName);
        
        // APENAS o SEGUNDO teste em diante é dependente
        // O primeiro teste não depende de ninguém
        if (testIndex > 0) {
          testSmells.add(TestSmell(
              name: testSmellName,
              testName: testName,
              testClass: testClass,
              code: 'Test depends on shared variable "$varName" modified by previous test(s): ${testList.sublist(0, testIndex).join(", ")}',
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