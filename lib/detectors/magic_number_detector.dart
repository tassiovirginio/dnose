import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class MagicNumberDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  String? codeTest;
  int startTest = 0, endTest = 0;

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
    if (e is ForPartsWithDeclarations || e is NamedExpression) return;

    if (e is IntegerLiteral || e is DoubleLiteral) {
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
    } else if (e is SimpleStringLiteral &&
        e.toSource().replaceAll("\"", "").contains(RegExp(r'^\d+$'))) {
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
  String get testSmellName => "Magic Number";

  @override
  String getDescription() {
    return '''
    Occurs when assert statements in a test method contain numeric literals (i.e., magic numbers) 
    as parameters. Magic numbers do not indicate the meaning/purpose of the number. Hence, they 
    should be replaced with constants or variables, thereby providing a descriptive name for the input.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Magic Number1", () => {expect(1 + 2, 3)}); //3

  test("Magic Number2", () => {expect("3", "3")}); //2

  test("Magic Number4", () {
    //1
    print(123);
  });

  test("Magic Number5", () {
    //1
    print("123");
  });
    ''';
  }
}
