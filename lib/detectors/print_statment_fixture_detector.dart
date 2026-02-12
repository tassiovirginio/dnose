import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class PrintStatmentFixtureDetector implements AbstractDetector {
  @override
  String get testSmellName => "Print Statment Fixture";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _PrintStatementVisitor(
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
    Print statements in unit tests are redundant as unit tests are executed as part of an 
    automated process with little to no human intervention. Print statements are possibly 
    used by developers for traceability and debugging purposes and then forgotten.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("PrintStatmentFixture1", () {
    var m = M();
    m.print("teste1");
    expect((2+2), 4, reason: "Verificando o valor 123");
    });
  test("PrintStatmentFixture2", () {
    var mm = M();
    mm.prints("teste1");
    });
  test("PrintStatmentFixture3", () => {print("teste1")});
  test("PrintStatmentFixture4", () => {prints("teste2")});
  test("PrintStatmentFixture5", () => {stdout.write("teste3")});
  test("PrintStatmentFixture6", () => {stderr.writeln("teste4")});
    ''';
  }
}

class _PrintStatementVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _PrintStatementVisitor({
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
      final parentStr = parent.toString();
      final name = node.name;

      final isPrint = (name == "print" && !parentStr.contains(".print"));
      final isStdoutWrite =
          (name == "write" &&
              (parent.beginToken.toString() == "stdout" ||
                  parent.beginToken.toString() == "stderr"));
      final isPrints = (name == "prints" && !parentStr.contains(".print"));
      final isWriteln =
          (name == "writeln" &&
              (parent.beginToken.toString() == "stdout" ||
                  parent.beginToken.toString() == "stderr"));

      if (isPrint || isStdoutWrite || isPrints || isWriteln) {
        testSmells.add(
          TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: parent.toSource(),
            codeMD5: Util.md5(parent.toSource()),
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
