import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class UnknownTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Unknown Test";

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

    // Collect assertions using a visitor
    final collector = _AssertionCollector();
    e.accept(collector);

    if (collector.assertions.isEmpty) {
      testSmells.add(createSmell(e));
    }

    return testSmells;
  }

  @override
  String getDescription() {
    return '''
    An assertion statement is used to declare an expected boolean condition for a test method.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("UnknownTest1", () {
    print("teste");
  });

  test("UnknownTest2", () {
    print("teste");
    if(true){
      print("teste");
    }
  });

  test("UnknownTest4", () {
    print("teste");
    if(true){
      print("teste");
    }
    // expect(1, 1, reason: "teste");
  });
    ''';
  }
}

/// Internal visitor to collect assertion method invocations.
class _AssertionCollector extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> assertions = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == "expect" ||
        node.methodName.name == "expectLater" ||
        node.methodName.name == "assert") {
      assertions.add(node);
    }
    super.visitMethodInvocation(node);
  }
}
