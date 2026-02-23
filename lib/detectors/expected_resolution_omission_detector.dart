import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ExpectedResolutionOmissionDetector extends AbstractDetector {
  @override
  get testSmellName => "Expected Resolution Omission";

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'expect') {
      _checkExpect(node);
    } else if (node.methodName.name == 'expectLater') {
      _checkExpectLater(node);
    }
    super.visitMethodInvocation(node);
  }

  void _checkExpect(MethodInvocation node) {
    var args = node.argumentList.arguments;
    if (args.length < 2) return;

    var actual = args[0];
    var matcher = args[1];

    if (_isFuture(actual) && !_hasAwait(actual) && !_isAsyncMatcher(matcher)) {
      _addSmell(node, 'Future without await or async matcher in expect()');
      return;
    }
  }

  void _checkExpectLater(MethodInvocation node) {
    var args = node.argumentList.arguments;
    if (args.length < 2) return;

    var actual = args[0];

    if (_hasAwait(actual)) {
      _addSmell(node, 'Unnecessary await in expectLater()');
      return;
    }
  }

  bool _isFuture(Expression expr) {
    var type = expr.staticType;
    if (type != null) {
      if (type is InterfaceType) {
        return type.isDartAsyncFuture || type.isDartAsyncFutureOr;
      }
      return false;
    }

    if (expr is MethodInvocation) {
      var target = expr.target;
      if (target is SimpleIdentifier && target.name == 'Future') {
        return true;
      }
      return false;
    }

    if (expr is SimpleIdentifier) {
      var name = expr.name.toLowerCase();
      return name == 'future' || name.endsWith('future');
    }

    if (expr is PropertyAccess || expr is PrefixedIdentifier) {
      return false;
    }

    return false;
  }

  bool _hasAwait(Expression expr) {
    return expr is AwaitExpression;
  }

  bool _isAsyncMatcher(Expression matcher) {
    if (matcher is SimpleIdentifier) {
      return _isAsyncMatcherName(matcher.name);
    }
    if (matcher is MethodInvocation) {
      return _isAsyncMatcherName(matcher.methodName.name);
    }
    return false;
  }

  bool _isAsyncMatcherName(String name) {
    const asyncMatchers = [
      'completion',
      'completes',
      'throwsA',
      'throwsException',
      'throwsArgumentError',
      'throwsStateError',
      'throwsFormatException',
      'throwsRangeError',
      'throwsNoSuchMethodError',
      'throwsUnimplementedError',
      'throwsUnsupportedError',
      'throwsConcurrentModificationError',
      'throwsCyclicInitializationError',
    ];
    return asyncMatchers.contains(name);
  }

  void _addSmell(MethodInvocation node, String reason) {
    testSmells.add(
      TestSmell(
        name: testSmellName,
        testName: testName,
        path: testClass.path,
        projectName: testClass.projectName,
        moduleAtual: testClass.moduleAtual,
        commit: testClass.commit,
        code: node.toSource(),
        codeMD5: Util.md5(node.toSource()),
        start: testClass.lineNumber(node.offset),
        end: testClass.lineNumber(node.end),
        collumnStart: testClass.columnNumber(node.offset),
        collumnEnd: testClass.columnNumber(node.end),
        codeTest: codeTest,
        codeTestMD5: Util.md5(codeTest),
        startTest: startTest,
        endTest: endTest,
        offset: node.offset,
        endOffset: node.end,
      ),
    );
  }

  @override
  String getDescription() {
    return '''
Detects 2 simple async issues in tests:
1. Future without await or async matcher in expect() - Testing Future with synchronous matcher
2. Unnecessary await in expectLater() - expectLater handles Futures automatically

Valid async matchers: completion(), completes, throwsA(), throwsException, etc.
''';
  }

  @override
  String getExample() {
    return '''
// WRONG:
expect(Future.value(42), equals(42));           // Missing await or async matcher
expectLater(await Future.value(42), completes); // Unnecessary await

// CORRECT:
expect(await Future.value(42), equals(42));     // With await
expect(Future.value(42), completion(equals(42)));  // With async matcher
expect(Future.value(42), completes);            // With async matcher
expectLater(Future.value(42), completes);       // No await needed
''';
  }
}
