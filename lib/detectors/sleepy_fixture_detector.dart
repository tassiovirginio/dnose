import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class SleepyFixtureDetector implements AbstractDetector {
  @override
  get testSmellName => "Sleepy Fixture";

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
    if (e is SimpleIdentifier &&
        (e.name == "sleep" && e.parent?.beginToken.toString() == "sleep" ||
            (e.name == "delayed" &&
                e.parent?.beginToken.toString() == "Future")) &&
        e.parent is MethodInvocation) {
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
    Explicitly causing a thread to sleep can lead to unexpected results as the processing time for a 
    task can differ on different devices. Developers introduce this smell when they need to pause 
    execution of statements in a test method for a certain duration (i.e. simulate an external 
    event) and then continuing with execution.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("SleepyFixture1",
      () async {
        await Future.delayed(Duration(seconds: 1));
        expect((2+2), 4, reason: "Verificando o valor 123");
        });

  test("SleepyFixture2", () async {
    m.sleep(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture3", () async {
    m.delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture4", () async{
    delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });
    ''';
  }
}
