import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ResourceOptimismDetector implements AbstractDetector {
  @override
  get testSmellName => "Resource Optimism";

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

    void processNode(AstNode node) {
      if (node is MethodInvocation) {
        final nodeSource = node.toSource();
        final nodeSourceNoSpaces = nodeSource.replaceAll(" ", "");

        if (nodeSourceNoSpaces.contains("File(")) {
          final hasExistsCheck =
              nodeSource.contains("exists(") ||
              nodeSource.contains("existsSync(");

          if (!hasExistsCheck) {
            testSmells.add(
              TestSmell(
                name: testSmellName,
                testName: testName,
                testClass: testClass,
                code: nodeSource,
                codeMD5: Util.md5(nodeSource),
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
          // NÃO processa filhos de MethodInvocation com File()
          return;
        }
      }

      // Processa filhos recursivamente
      for (final child in node.childEntities.whereType<AstNode>()) {
        processNode(child);
      }
    }

    processNode(e);
    return testSmells;
  }

  @override
  String getDescription() {
    return '''
    This smell occurs when a test method makes an optimistic assumption that the external resource 
    (e.g., File), utilized by the test method, exists.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("DetectorResourceOptimism1", () {
    // ignore: unused_local_variable
    var file = File('file.txt');
  });
    ''';
  }
}
