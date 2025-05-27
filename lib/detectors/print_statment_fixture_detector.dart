import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class PrintStatmentFixtureDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

  @override
  String get testSmellName => "Print Statment Fixture";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is SimpleIdentifier &&
        ((e.name == "print" &&
                e.parent.toString().contains(".print") == false) ||
            (e.name == "write" &&
                (e.parent?.beginToken.toString() == "stdout" ||
                    e.parent?.beginToken.toString() == "stderr")) ||
            (e.name == "prints" &&
                e.parent.toString().contains(".print") == false) ||
            (e.name == "writeln" &&
                (e.parent?.beginToken.toString() == "stdout" ||
                    e.parent?.beginToken.toString() == "stderr"))) &&
        e.parent is MethodInvocation) {
      testSmells.add(
        TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.parent!.toSource(),
          codeMD5: Util.md5(e.parent!.toSource()),
          codeTest: codeTest,
          codeTestMD5: Util.md5(codeTest!),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          offset: e.offset,
          endOffset: e.end,
        ),
      );
    }
    e.childEntities.whereType<AstNode>().forEach(
      (e) => _detect(e, testClass, testName),
    );
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
