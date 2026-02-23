import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class DuplicateAssertDetector extends AbstractDetector {
  @override
  get testSmellName => "Duplicate Assert";

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

    // Collect all method invocations using a visitor
    final collector = _MethodInvocationCollector();
    e.accept(collector);

    Map<String, List<MethodInvocation>> mapMethodInvocation = {};

    for (var item2 in collector.methods) {
      String item = item2.methodName.name;
      if (item != "test" && item != "expect") {
        if (mapMethodInvocation.containsKey(item)) {
          mapMethodInvocation[item]?.add(item2);
        } else {
          mapMethodInvocation[item] = List.empty(growable: true);
          mapMethodInvocation[item]?.add(item2);
        }
      }
    }

    for (List<MethodInvocation> items in mapMethodInvocation.values) {
      if (items.length > 1) {
        items.removeLast();
        for (var value in items) {
          testSmells.add(
            TestSmell(
              name: testSmellName,
              testName: testName,
              path: testClass.path,
              projectName: testClass.projectName,
              moduleAtual: testClass.moduleAtual,
              commit: testClass.commit,
              code: e.toSource(),
              codeMD5: Util.md5(e.toSource()),
              codeTest: codeTest,
              codeTestMD5: Util.md5(codeTest),
              startTest: startTest,
              endTest: endTest,
              start: testClass.lineNumber(value.offset),
              end: testClass.lineNumber(value.offset),
              collumnStart: testClass.columnNumber(value.offset),
              collumnEnd: testClass.columnNumber(value.offset),
              offset: e.offset,
              endOffset: e.end,
            ),
          );
        }
      }
    }

    return testSmells;
  }

  @override
  String getDescription() {
    return '''
    This smell occurs when a test method tests for the same condition multiple times 
    within the same test method. If the test method needs to test the same condition 
    using different values, a new test method should be utilized; the name of the test 
    method should be an indication of the test being performed. Possible situations that 
    would give rise to this smell include: (1) developers grouping multiple conditions 
    to test a single method; (2) developers performing debugging activities; and (3) 
    an accidental copy-paste of code.
    ''';
  }

  @override
  String getExample() {
    return '''
        test("Duplicate Assert1", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
  });


  test("Duplicate Assert2", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(2,2), 4, reason: "Verificando o valor");
    expect(sum(2,3), 5, reason: "Verificando o valor");
  });


  test("Duplicate Assert3", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor 123");
    expect(sum(1,2), 3, reason: "Verificando o valor 321");
    expect(sum(1,2), 3, reason: "Verificando o valor 111");
  });

  test("Duplicate Assert4", () { // 1
    expect(sum(1,3), 4, reason: "Verificando o valor 123");
    expect(sum(1,3), 4, reason: "Verificando o valor 321");
    expect(sum2(1,3), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert5", () { // 1
    expect(sum(2,2), 4, reason: "Verificando o valor 123");
    expect(sum(2,2), 4, reason: "Verificando o valor 321");
    expect(sum2(2,2), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert6", () { // 2
    expect(sum(1,3), 4, reason: "Verificando o valor 123");
    expect(sum(2,2), 4, reason: "Verificando o valor 321");
    expect(sum2(2,2), 4, reason: "Verificando o valor 123");
    expect(sum2(1,3), 4, reason: "Verificando o valor 123");
  });
        ''';
  }
}

/// Internal visitor to collect all MethodInvocation nodes.
class _MethodInvocationCollector extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> methods = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    methods.add(node);
    super.visitMethodInvocation(node);
  }
}
