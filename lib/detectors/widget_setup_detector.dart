import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class WidgetSetupDetector implements AbstractDetector {
  @override
  get testSmellName => "Widget Setup";

  static Map<String, Map<String, List<TestSetupInfo>>> globalSetupPatterns = {};

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    return [];
  }

  static void reset() {
    globalSetupPatterns.clear();
  }

  static void collectSetupPatterns(
      ExpressionStatement e, TestClass testClass, String testName) {
    String filePath = testClass.path;
    
    if (!globalSetupPatterns.containsKey(filePath)) {
      globalSetupPatterns[filePath] = {};
    }
    
    String? setupPattern = _extractSetupPattern(e);
    
    if (setupPattern != null) {
      if (!globalSetupPatterns[filePath]!.containsKey(setupPattern)) {
        globalSetupPatterns[filePath]![setupPattern] = [];
      }
      globalSetupPatterns[filePath]![setupPattern]!.add(
        TestSetupInfo(testName, e, testClass)
      );
    }
  }

  static String? _extractSetupPattern(AstNode node) {
    MethodInvocation? pumpWidgetCall = _findPumpWidget(node);
    
    if (pumpWidgetCall == null) return null;
    
    if (pumpWidgetCall.argumentList.arguments.isEmpty) return null;
    
    Expression widgetArg = pumpWidgetCall.argumentList.arguments.first;
    
    // If the argument is a variable reference, skip it
    if (widgetArg is SimpleIdentifier ||
        widgetArg is PrefixedIdentifier) {
      return null;
    }
    
    // If it's a MethodInvocation, check if it's a constructor (PascalCase)
    // or a factory/helper function (camelCase)
    // Without 'new' keyword, Dart parser treats constructors as MethodInvocation
    if (widgetArg is MethodInvocation) {
      String methodName = widgetArg.methodName.name;
      // Factory/helper functions start with lowercase (e.g., buildGrid, createWidget)
      if (methodName.isNotEmpty && methodName[0] == methodName[0].toLowerCase()) {
        return null; // This is a factory/helper function — NOT inline widget tree
      }
      // PascalCase = constructor (e.g., MaterialApp, MyWidget) — continue to normalize
    }
    
    String? pattern = _normalizeWidgetStructure(widgetArg);
    
    // Reject if normalization returned LOCAL_REF or null
    if (pattern == null || pattern == 'LOCAL_REF') return null;
    
    return pattern;
  }

  static MethodInvocation? _findPumpWidget(AstNode node) {
    if (node is MethodInvocation) {
      if (node.methodName.name == 'pumpWidget') {
        return node;
      }
    }
    
    for (var child in node.childEntities.whereType<AstNode>()) {
      var result = _findPumpWidget(child);
      if (result != null) return result;
    }
    
    return null;
  }

  static String? _normalizeWidgetStructure(Expression expr) {
    if (expr is InstanceCreationExpression) {
      String typeName = expr.constructorName.type.toString();
      
      List<String> childPatterns = [];
      bool hasLocalReference = false;
      
      for (var arg in expr.argumentList.arguments) {
        if (arg is NamedExpression) {
          String argName = arg.name.label.name;
          String? argValue = _normalizeWidgetStructure(arg.expression);
          // If child has a local reference, mark it
          if (argValue == null || argValue == 'LOCAL_REF') {
            hasLocalReference = true;
            continue;
          }
          childPatterns.add('$argName:$argValue');
        } else {
          String? argValue = _normalizeWidgetStructure(arg);
          // If child has a local reference, mark it
          if (argValue == null || argValue == 'LOCAL_REF') {
            hasLocalReference = true;
            continue;
          }
          childPatterns.add(argValue);
        }
      }
      
      if (hasLocalReference) {
        return null;
      }
      
      if (childPatterns.isEmpty) {
        return typeName;
      }
      
      childPatterns.sort();
      return '$typeName(${childPatterns.join(',')})';
    }
    
    if (expr is ListLiteral) {
      return 'List';
    }
    
    if (expr is FunctionExpression) {
      return 'Function';
    }
    

    if (expr is SimpleIdentifier) {
      return 'LOCAL_REF';
    }
    
    if (expr is PrefixedIdentifier) {
      return 'LOCAL_REF';
    }
    
    // MethodInvocation inside inline widget tree = widget constructor (e.g. Text(), Icon())
    // In static AST without type resolution, constructors are parsed as MethodInvocation.
    // Top-level factory calls like buildGrid() are already filtered in _extractSetupPattern.
    if (expr is MethodInvocation) {
      String methodName = expr.methodName.name;
      
      List<String> childPatterns = [];
      for (var arg in expr.argumentList.arguments) {
        if (arg is NamedExpression) {
          String argName = arg.name.label.name;
          String? argValue = _normalizeWidgetStructure(arg.expression);
          if (argValue == null || argValue == 'LOCAL_REF') continue;
          childPatterns.add('$argName:$argValue');
        } else {
          String? argValue = _normalizeWidgetStructure(arg);
          if (argValue == null || argValue == 'LOCAL_REF') continue;
          childPatterns.add(argValue);
        }
      }
      
      if (childPatterns.isEmpty) {
        return methodName;
      }
      childPatterns.sort();
      return '$methodName(${childPatterns.join(',')})';
    }
    
    return expr.runtimeType.toString();
  }

  static List<TestSmell> detectWidgetSetup() {
    List<TestSmell> smells = [];
    
    for (var fileEntry in globalSetupPatterns.entries) {
      for (var patternEntry in fileEntry.value.entries) {
        if (patternEntry.value.length >= 3) {
          for (var setupInfo in patternEntry.value) {
            smells.add(TestSmell(
                name: "Widget Setup",
                testName: setupInfo.testName,
                testClass: setupInfo.testClass,
                code: setupInfo.expression.toSource(),
                codeMD5: Util.md5(setupInfo.expression.toSource()),
                start: setupInfo.testClass.lineNumber(setupInfo.expression.offset),
                end: setupInfo.testClass.lineNumber(setupInfo.expression.end),
                collumnStart: setupInfo.testClass.columnNumber(setupInfo.expression.offset),
                collumnEnd: setupInfo.testClass.columnNumber(setupInfo.expression.end),
                codeTest: setupInfo.expression.toSource(),
                codeTestMD5: Util.md5(setupInfo.expression.toSource()),
                startTest: setupInfo.testClass.lineNumber(setupInfo.expression.offset),
                endTest: setupInfo.testClass.lineNumber(setupInfo.expression.end),
                offset: setupInfo.expression.offset,
                endOffset: setupInfo.expression.end));
          }
        }
      }
    }
    
    return smells;
  }

  @override
  String getDescription() {
    return
      '''
      Occurs when widget configurations or initializations are repeated unnecessarily across 
      multiple tests. This increases complexity, reduces code clarity, and makes test 
      maintenance more difficult. Common signs include duplicated pumpWidget calls with 
      similar widget structures.
      '''
      ;
  }

  @override
  String getExample() {
    return
      '''
      // Problematic example:
      testWidgets('Test 1', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Text('Test 1')),
          ),
        );
      });
      
      testWidgets('Test 2', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Text('Test 2')),
          ),
        );
      });

      // Correct example:
      Widget buildTestWidget(String text) {
        return MaterialApp(
          home: Scaffold(body: Text(text)),
        );
      }
      
      testWidgets('Test 1', (tester) async {
        await tester.pumpWidget(buildTestWidget('Test 1'));
      });
      '''
    ;
  }
}

class TestSetupInfo {
  final String testName;
  final ExpressionStatement expression;
  final TestClass testClass;
  
  TestSetupInfo(this.testName, this.expression, this.testClass);
}
