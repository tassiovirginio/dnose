import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class DuplicateAssertDetector implements AbstractDetector {
  @override
  get testSmellName => "Duplicate Assert";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final codeTest = e.toSource();
    final startTest = testClass.lineNumber(e.offset);
    final endTest = testClass.lineNumber(e.end);
    final testSmells = <TestSmell>[];

    final mapMethodInvocation = <String, List<MethodInvocation>>{};

    // Collect all method invocations
    List<MethodInvocation> collectMethodInvocations(AstNode node) {
      final result = <MethodInvocation>[];
      if (node is MethodInvocation) {
        result.add(node);
      }
      for (final child in node.childEntities.whereType<AstNode>()) {
        result.addAll(collectMethodInvocations(child));
      }
      return result;
    }

    final allInvocations = collectMethodInvocations(e);

    for (final invocation in allInvocations) {
      final methodName = invocation.methodName.name;
      if (methodName != "test" && methodName != "expect") {
        if (mapMethodInvocation.containsKey(methodName)) {
          mapMethodInvocation[methodName]!.add(invocation);
        } else {
          mapMethodInvocation[methodName] = [invocation];
        }
      }
    }

    // Process duplicates
    for (final items in mapMethodInvocation.values) {
      if (items.length > 1) {
        // Removendo o ultimo
        final itemsToMark = items.sublist(0, items.length - 1);
        for (final value in itemsToMark) {
          testSmells.add(
            TestSmell(
              name: testSmellName,
              testName: testName,
              testClass: testClass,
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
