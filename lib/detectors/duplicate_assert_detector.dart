import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class DuplicateAssertDetector implements AbstractDetector {
  @override
  get testSmellName => "Duplicate Assert";

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

  Map<String, List<MethodInvocation>> mapMethodInvocation =
      <String, List<MethodInvocation>>{};

  List<MethodInvocation> listMethodInvocation = List.empty(growable: true);

  void _detect(AstNode e, TestClass testClass, String testName) {
    // if( e is MethodInvocation && e.beginToken.toString() == "expect" && e.childEntities.elementAt(1) is ArgumentList){
    listMethodInvocation.addAll(flow(e));
    // }

    for (var item2 in listMethodInvocation) {
      String item = item2.methodName.name;
      if (item != "test" && item != "expect") {
        if (mapMethodInvocation.containsKey(item)) {
          mapMethodInvocation[item]?.add(item2);
        } else {
          mapMethodInvocation[item] = List.empty(growable: true);
          mapMethodInvocation[item]?.add(item2);
        }
      }
    }

    for (List<MethodInvocation> items in mapMethodInvocation.values) {
      if (items.length > 1) {
        items.removeLast(); //Removendo o ultimo
        for (var value in items) {
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
              start: testClass.lineNumber(value.offset),
              end: testClass.lineNumber(value.offset),
              collumnStart: testClass.columnNumber(value.offset),
              collumnEnd: testClass.columnNumber(value.offset),
              offset: e.offset,
              endOffset: e.end,
            ),
          );
        }
      }
    }
  }

  @override
  String getDescription() {
    return
    '''
    This smell occurs when a test method tests for the same condition multiple times 
    within the same test method. If the test method needs to test the same condition 
    using different values, a new test method should be utilized; the name of the test 
    method should be an indication of the test being performed. Possible situations that 
    would give rise to this smell include: (1) developers grouping multiple conditions 
    to test a single method; (2) developers performing debugging activities; and (3) 
    an accidental copy-paste of code.
    '''
    ;
  }


  @override
  String getExample() {
    return
        '''
        test("Duplicate Assert1", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
  });


  test("Duplicate Assert2", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(2,2), 4, reason: "Verificando o valor");
    expect(sum(2,3), 5, reason: "Verificando o valor");
  });


  test("Duplicate Assert3", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor 123");
    expect(sum(1,2), 3, reason: "Verificando o valor 321");
    expect(sum(1,2), 3, reason: "Verificando o valor 111");
  });

  test("Duplicate Assert4", () { // 1
    expect(sum(1,3), 4, reason: "Verificando o valor 123");
    expect(sum(1,3), 4, reason: "Verificando o valor 321");
    expect(sum2(1,3), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert5", () { // 1
    expect(sum(2,2), 4, reason: "Verificando o valor 123");
    expect(sum(2,2), 4, reason: "Verificando o valor 321");
    expect(sum2(2,2), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert6", () { // 2
    expect(sum(1,3), 4, reason: "Verificando o valor 123");
    expect(sum(2,2), 4, reason: "Verificando o valor 321");
    expect(sum2(2,2), 4, reason: "Verificando o valor 123");
    expect(sum2(1,3), 4, reason: "Verificando o valor 123");
  });
        '''
        ;
  }


}

List<MethodInvocation> flow(AstNode e) {
  List<MethodInvocation> listMethods = List.empty(growable: true);

  if (e is MethodInvocation) {
    listMethods.add(e);
  }

  List lista = e.childEntities.toList();
  for (var e2 in lista) {
    if (e2 is AstNode) {
      listMethods.addAll(flow(e2));
    }
  }

  return listMethods;
}
