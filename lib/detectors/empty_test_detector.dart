import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class EmptyTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Empty Test";

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

  int cont = 0;
  String code_1 = "";

  void _detect(AstNode e, TestClass testClass, String testName) {
    //Melhorar - encontrar somente quando setado em uma variável
    if (e is FunctionExpression &&
        e.parent is ArgumentList &&
        e.parent!.parent is MethodInvocation &&
        e.parent!.parent!.parent is ExpressionStatement &&
        e.parent!.parent!.parent!.parent is Block &&
        e.parent!.parent!.childEntities.first.toString() == "test" &&
        (e.toString().replaceAll(" ", "") == "()=>{}" ||
            e.toString().replaceAll(" ", "") == "{}" ||
            e.toString().replaceAll(" ", "") == "(){}")) {
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
    e.childEntities.whereType<AstNode>().forEach(
      (e) => _detect(e, testClass, testName),
    );
  }

  @override
  String getDescription() {
    return '''
        Occurs when a test method does not contain executable statements. Such methods are 
        possibly created for debugging purposes and then forgotten about or contains commented 
        out code. An empty test can be considered problematic and more dangerous than not having 
        a test case at all since JUnit will indicate that the test passes even if there are no 
        executable statements present in the method body. As such, developers introducing 
        behavior-breaking changes into production class, 
        will not be notified of the alternated outcomes as JUnit will report the test as passing.
        ''';
  }

  @override
  String getExample() {
    return '''
        test("EmptyFixture1", () => {});
  test("EmptyFixture2", () => {     });
  test("EmptyFixture3", () {});
  test("EmptyFixture4", () {
    //comentário
  });
        ''';
  }
}
