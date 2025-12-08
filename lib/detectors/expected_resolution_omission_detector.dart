import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ExpectedResolutionOmissionDetector implements AbstractDetector {
@override
get testSmellName => "Expected Resolution Omission";

List<TestSmell> testSmells = List.empty(growable: true);

String? codeTest;
int startTest = 0, endTest = 0;

@override
List<TestSmell> detect(
ExpressionStatement e, TestClass testClass, String testName) {
codeTest = e.toSource();
startTest = testClass.lineNumber(e.offset);
endTest = testClass.lineNumber(e.end);
_detect(e, testClass, testName);
return testSmells;
}

void _detect(AstNode node, TestClass testClass, String testName) {
if (node is MethodInvocation && node.methodName.name == 'expect') {
var args = node.argumentList.arguments;
if (args.length >= 2) {
var actual = args[0];
var matcher = args[1];


    // Case 1: expect() com Future mas sem await
    if (_isFutureExpression(actual) && !_hasAwait(actual)) {
      _addSmell(node, testClass, testName);
    }

    // Case 2: await desnecessário em algo não-Future
    if (_isUnnecessaryAwait(actual)) {
      _addSmell(node, testClass, testName);
    }

    // Case 3: testando exceções sem throwsA
    if (_isExceptionTestWithoutThrowsA(actual, matcher)) {
      _addSmell(node, testClass, testName);
    }
  }
}

node.childEntities
    .whereType<AstNode>()
    .forEach((child) => _detect(child, testClass, testName));


}

bool _isFutureExpression(Expression expr) {
var type = expr.staticType;
return type is InterfaceType && type.isDartAsyncFuture;
}

bool _hasAwait(Expression expr) {
AstNode? parent = expr.parent;
while (parent != null) {
if (parent is AwaitExpression) return true;
if (parent is ExpressionStatement) break;
parent = parent.parent;
}
return false;
}

bool _isUnnecessaryAwait(Expression expr) {
if (expr is AwaitExpression) {
var awaitedType = expr.expression.staticType;
if (awaitedType != null && !awaitedType.isDartAsyncFuture) {
return true;
}
}
return false;
}

bool _isExceptionTestWithoutThrowsA(Expression actual, Expression matcher) {
if (matcher is MethodInvocation) {
// Matcher já é throwsA -> OK
if (matcher.methodName.name == 'throwsA') return false;
}


// Verifica se o actual é Future que lança erro
if (_isFutureExpression(actual)) {
  // Não é obrigatório, mas pode ser Future.error ou Future.delayed
  // Não confiamos mais no texto, apenas detectamos se matcher não é throwsA
  return true;
}

return false;


}

void _addSmell(
MethodInvocation node, TestClass testClass, String testName) {
testSmells.add(TestSmell(
name: testSmellName,
testName: testName,
testClass: testClass,
code: node.toSource(),
codeMD5: Util.md5(node.toSource()),
start: testClass.lineNumber(node.offset),
end: testClass.lineNumber(node.end),
collumnStart: testClass.columnNumber(node.offset),
collumnEnd: testClass.columnNumber(node.end),
codeTest: codeTest,
codeTestMD5: Util.md5(codeTest!),
startTest: startTest,
endTest: endTest,
offset: node.offset,
endOffset: node.end,
));
}

@override
String getDescription() {
return '''
Occurs when async test code has issues with await, expect, or expectLater usage.
This can lead to tests that pass incorrectly or fail due to synchronization problems.
Common issues include missing await on Futures, unnecessary await on non-async code,
or improper exception testing without throwsA matcher.
''';
}

@override
String getExample() {
return '''
// Problematic examples:
test('async test without await', () {
final future = Future.value(42);
expect(future, equals(42)); // Missing await
});

test('unnecessary await', () {
expect(await 42, equals(42)); // Unnecessary await
});

test('exception without throwsA', () {
final future = Future.error(Exception('fail'));
expect(future, isA<Exception>()); // Should use throwsA
});

// Correct examples:
test('proper async test', () async {
final future = Future.value(42);
expect(await future, equals(42));
});

test('exception with throwsA', () {
final future = Future.error(Exception('fail'));
expect(future, throwsA(isA<Exception>()));
});
''';
}
}
