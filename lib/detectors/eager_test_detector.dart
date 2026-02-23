import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';

class EagerTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Eager Test";

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

    Map<String, Set<String>> objectMethods = {};
    _collectMethodCalls(e, objectMethods);

    for (var entry in objectMethods.entries) {
      if (entry.value.length >= 3) {
        testSmells.add(createSmell(e));
        break;
      }
    }

    return testSmells;
  }

  void _collectMethodCalls(
    AstNode node,
    Map<String, Set<String>> objectMethods,
  ) {
    if (node is MethodInvocation) {
      var target = node.target;
      if (target is SimpleIdentifier) {
        String objectName = target.name;
        String methodName = node.methodName.name;

        objectMethods.putIfAbsent(objectName, () => {});
        objectMethods[objectName]!.add(methodName);
      } else if (target is MethodInvocation) {
        _collectMethodCalls(target, objectMethods);
      }
    }

    node.childEntities.whereType<AstNode>().forEach(
      (child) => _collectMethodCalls(child, objectMethods),
    );
  }

  @override
  String getDescription() {
    return '''
      Occurs when a test method calls three or more distinct production methods on the same object.
      This indicates that the test is trying to verify multiple behaviors at once, making it harder
      to understand what is being tested and which behavior caused a failure.
      ''';
  }

  @override
  String getExample() {
    return '''
      // Problematic example:
      test('Eager test with multiple methods', () {
        final flight = Flight('AA123');
        flight.setMileage(1122);
        flight.getMileageAsKm();
        flight.cancel(); // Testing 3+ different methods
      });

      // Correct example:
      test('Single method test', () {
        final calc = Calculator();
        expect(calc.add(2, 3), equals(5));
      });
      ''';
  }
}
