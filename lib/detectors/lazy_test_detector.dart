import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class LazyTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Lazy Test";

  List<TestSmell> testSmells = List.empty(growable: true);
  
  static Map<String, Map<String, List<TestMethodInfo>>> globalMethodCalls = {};

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    return [];
  }

  static void reset() {
    globalMethodCalls.clear();
  }

  static void collectMethodCalls(
      ExpressionStatement e, TestClass testClass, String testName) {
    String filePath = testClass.path;
    
    if (!globalMethodCalls.containsKey(filePath)) {
      globalMethodCalls[filePath] = {};
    }
    
    Set<String> methodsInTest = {};
    _collectMethods(e, methodsInTest);
    
    for (var method in methodsInTest) {
      if (!globalMethodCalls[filePath]!.containsKey(method)) {
        globalMethodCalls[filePath]![method] = [];
      }
      globalMethodCalls[filePath]![method]!.add(
        TestMethodInfo(testName, e, testClass)
      );
    }
  }

  static void _collectMethods(AstNode node, Set<String> methods) {
    if (node is MethodInvocation) {
      var target = node.target;
      if (target is SimpleIdentifier || target is MethodInvocation) {
        String methodName = node.methodName.name;
        
        if (methodName != 'expect' && 
            methodName != 'equals' && 
            methodName != 'test' &&
            methodName != 'setUp' &&
            methodName != 'tearDown' &&
            methodName != 'group') {
          methods.add(methodName);
        }
      }
    }
    
    node.childEntities
        .whereType<AstNode>()
        .forEach((child) => _collectMethods(child, methods));
  }

  static List<TestSmell> detectLazyTests() {
    List<TestSmell> smells = [];
    
    for (var fileEntry in globalMethodCalls.entries) {
      for (var methodEntry in fileEntry.value.entries) {
        if (methodEntry.value.length >= 2) {
          for (var testInfo in methodEntry.value) {
            smells.add(TestSmell(
                name: "Lazy Test",
                testName: testInfo.testName,
                testClass: testInfo.testClass,
                code: testInfo.expression.toSource(),
                codeMD5: Util.md5(testInfo.expression.toSource()),
                start: testInfo.testClass.lineNumber(testInfo.expression.offset),
                end: testInfo.testClass.lineNumber(testInfo.expression.end),
                collumnStart: testInfo.testClass.columnNumber(testInfo.expression.offset),
                collumnEnd: testInfo.testClass.columnNumber(testInfo.expression.end),
                codeTest: testInfo.expression.toSource(),
                codeTestMD5: Util.md5(testInfo.expression.toSource()),
                startTest: testInfo.testClass.lineNumber(testInfo.expression.offset),
                endTest: testInfo.testClass.lineNumber(testInfo.expression.end),
                offset: testInfo.expression.offset,
                endOffset: testInfo.expression.end));
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
      Occurs when multiple test methods invoke the same method of the production object.
      This smell affects test maintainability, as assertions testing the same method should
      be in the same test case. Multiple tests calling the same production method indicate
      that the test suite may be poorly organized.
      '''
      ;
  }

  @override
  String getExample() {
    return
      '''
      // Problematic example:
      test('Test decrypt case 1', () {
        var result = Cryptographer.decrypt(data1, key);
        expect(result, expected1);
      });
      
      test('Test decrypt case 2', () {
        var result = Cryptographer.decrypt(data2, key);
        expect(result, expected2);
      });

      // Correct example:
      test('Test decrypt all cases', () {
        expect(Cryptographer.decrypt(data1, key), expected1);
        expect(Cryptographer.decrypt(data2, key), expected2);
      });
      '''
    ;
  }
}

class TestMethodInfo {
  final String testName;
  final ExpressionStatement expression;
  final TestClass testClass;
  
  TestMethodInfo(this.testName, this.expression, this.testClass);
}
