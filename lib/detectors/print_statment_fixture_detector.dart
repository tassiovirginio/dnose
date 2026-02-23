import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class PrintStatmentFixtureDetector extends AbstractDetector {
  @override
  String get testSmellName => "Print Statment Fixture";

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (((node.name == "print" &&
                node.parent.toString().contains(".print") == false) ||
            (node.name == "write" &&
                (node.parent?.beginToken.toString() == "stdout" ||
                    node.parent?.beginToken.toString() == "stderr")) ||
            (node.name == "prints" &&
                node.parent.toString().contains(".print") == false) ||
            (node.name == "writeln" &&
                (node.parent?.beginToken.toString() == "stdout" ||
                    node.parent?.beginToken.toString() == "stderr"))) &&
        node.parent is MethodInvocation) {
      // Uses parent node for code (preserving original behavior)
      testSmells.add(
        TestSmell(
          name: testSmellName,
          testName: testName,
          path: testClass.path,
          projectName: testClass.projectName,
          moduleAtual: testClass.moduleAtual,
          commit: testClass.commit,
          code: node.parent!.toSource(),
          codeMD5: Util.md5(node.parent!.toSource()),
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
    super.visitSimpleIdentifier(node);
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
