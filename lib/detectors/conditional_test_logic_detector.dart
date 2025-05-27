import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ConditionalTestLogicDetector implements AbstractDetector {
  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  get testSmellName => "Conditional Test Logic";

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
    _detect(e, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {
    if (e is ForElement ||
        e is ForStatement ||
        e is IfElement ||
        e is IfStatement ||
        e is WhileStatement ||
        e is SwitchStatement ||
        (e is SimpleIdentifier && e.name == "forEach")) {
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
    return
        '''
        Test methods need to be simple and execute all statements in the production method. 
        Conditions within the test method will alter the behavior of the test and its expected output, 
        and would lead to situations where the test fails to detect defects in the production method 
        since test statements were not executed as a condition was not met. Furthermore, 
        conditional code within a test method negatively impacts the ease of comprehension by developers.
        '''
    ;
  }


  @override
  String getExample() {
    return
        '''
  test("Conditional Test Logic IF1", () => {if (true) {}});//1
  
  test("Conditional Test Logic IF2", () => {if (true) {} else if (false) {}});//2

  test("Conditional Test Logic IF3", () {//2
    while (true) {
      if (true) {}
    }
  }, skip: true);

  test("Conditional Test Logic FOR", () => {for (int i = 0; i < 10; i++) {}});//1

  test("Conditional Test Logic WHILE1", () {//1
    while (true) {}
  }, skip: true);

  test("Conditional Test Logic WHILE2", () {//1
    print("");
    while (1 == 1) {}
  },skip: true);


  test("Conditional Test Logic Switch", () {//1
    switch (1) {
      case 1:
        break;
      default:
    }
  },skip: true);

  test("Conditional Test Logic forEach", () {//1
    List<int> list = [1,2,3];
    for (var number in list) {
      print(number);
    }
  });
        '''
        ;
  }
}
