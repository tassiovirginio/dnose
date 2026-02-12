import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class SleepyFixtureDetector implements AbstractDetector {
  @override
  get testSmellName => "Sleepy Fixture";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _SleepyFixtureVisitor(
      testClass: testClass,
      testName: testName,
      testSmellName: testSmellName,
      codeTest: e.toSource(),
      startTest: testClass.lineNumber(e.offset),
      endTest: testClass.lineNumber(e.end),
    );
    e.accept(visitor);
    return visitor.testSmells;
  }

  @override
  String getDescription() {
    return '''
    Explicitly causing a thread to sleep can lead to unexpected results as the processing time for a 
    task can differ on different devices. Developers introduce this smell when they need to pause 
    execution of statements in a test method for a certain duration (i.e. simulate an external 
    event) and then continuing with execution.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("SleepyFixture1",
      () async {
        await Future.delayed(Duration(seconds: 1));
        expect((2+2), 4, reason: "Verificando o valor 123");
        });

  test("SleepyFixture2", () async {
    m.sleep(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture3", () async {
    m.delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture4", () async{
    delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });
    ''';
  }
}

class _SleepyFixtureVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _SleepyFixtureVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final parent = node.parent;
    if (parent is MethodInvocation) {
      final name = node.name;
      final parentBeginToken = parent.beginToken.toString();

      final isSleep = (name == "sleep" && parentBeginToken == "sleep");
      final isFutureDelayed =
          (name == "delayed" && parentBeginToken == "Future");

      if ((isSleep || isFutureDelayed)) {
        testSmells.add(
          TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: node.toSource(),
            codeMD5: Util.md5(node.toSource()),
            codeTest: codeTest,
            codeTestMD5: Util.md5(codeTest),
            startTest: startTest,
            endTest: endTest,
            start: testClass.lineNumber(node.offset),
            end: testClass.lineNumber(node.end),
            collumnStart: testClass.columnNumber(node.offset),
            collumnEnd: testClass.columnNumber(node.end),
            offset: node.offset,
            endOffset: node.end,
          ),
        );
      }
    }
    super.visitSimpleIdentifier(node);
  }
}
