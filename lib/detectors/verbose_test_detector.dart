import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class VerboseTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Verbose Test";

  static const valueMaxLineVerbose = 30;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.toString() == "test" && node.parent is MethodInvocation) {
      int start = _lineNumber(
        node.root as CompilationUnit,
        node.parent!.offset,
      );
      int end = _lineNumber(node.root as CompilationUnit, node.parent!.end);

      if (end - start > valueMaxLineVerbose) {
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
            codeTest: codeTest,
            codeTestMD5: Util.md5(codeTest),
            startTest: startTest,
            endTest: endTest,
            start: testClass.lineNumber(node.parent!.offset),
            end: testClass.lineNumber(node.parent!.end),
            collumnStart: testClass.columnNumber(node.offset),
            collumnEnd: testClass.columnNumber(node.end),
            offset: node.offset,
            endOffset: node.end,
          ),
        );
        // Don't recurse (preserving original else-branch behavior)
        return;
      }
    }
    super.visitSimpleIdentifier(node);
  }

  int _lineNumber(CompilationUnit cu, int offset) =>
      cu.lineInfo.getLocation(offset).lineNumber;

  @override
  String getDescription() {
    return '''
    The 'Verbose Test' test smell occurs when a test method is excessively long, 
    typically with more than 30 lines of code. Verbose test methods can indicate that 
    the method has multiple responsibilities, making it difficult to understand and maintain.
     Maintaining such test methods can be complicated, as changes in one part of the test can 
     affect other parts, increasing the likelihood of introducing errors.
    ''';
  }

  @override
  String getExample() {
    return '''
    test(
      "VerboseFixture",
      () => {
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3),
            expect(1 + 2, 3)
          });
    ''';
  }
}
