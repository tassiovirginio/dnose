import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ResourceOptimismDetector implements AbstractDetector {
  @override
  get testSmellName => "Resource Optimism";

  String? codeTest;
  int startTest = 0, endTest = 0;

  List<TestSmell> testSmells = List.empty(growable: true);

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
    if (e is MethodInvocation &&
        e.toSource().replaceAll(" ", "").contains("File(")) {
      if ((e.toSource().contains("exists(") ||
              e.toSource().contains("existsSync(")) ==
          false) {
        testSmells.add(
          TestSmell(
            name: testSmellName,
            testName: testName,
            testClass: testClass,
            code: e.toSource(),
            codeMD5: Util.md5(e.toSource()),
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
    } else {
      e.childEntities.whereType<AstNode>().forEach(
        (e) => _detect(e, testClass, testName),
      );
    }
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
