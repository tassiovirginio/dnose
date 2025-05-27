import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class IgnoredTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Ignored Test";

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
    if (e is NamedExpression &&
        e.parent is ArgumentList &&
        (e.toString().contains("skip: true") ||
            e.toString().contains("skip:true") ||
            e.toString().contains("skip: \""))) {
      if (e.childEntities.elementAt(0) is Label &&
          e.childEntities.elementAt(0).toString() == "skip:" &&
          e.childEntities.elementAt(1).toString() != "false") {
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
    Testing in Dart offers developers the ability to suppress the execution of test methods. 
    However, these ignored test methods result in overhead, as they add unnecessary cost regarding 
    compilation time and increase code complexity and comprehension difficulty.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Some Test1", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:        true);

  test("Some Test2", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "Message Ignore");


  test("Some Test3", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "");

  test("Some Test4", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "     ");
    ''';
  }
}
