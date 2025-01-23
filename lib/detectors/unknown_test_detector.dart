import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class UnknownTestDetector implements AbstractDetector {
  @override
  get testSmellName => "Unknown Test";

  String? codeTest;
  int startTest = 0, endTest = 0;

  List<TestSmell> testSmells = List.empty(growable: true);

  @override
  List<TestSmell> detect(
      ExpressionStatement e, TestClass testClass, String testName) {
    codeTest = e.toSource();
    startTest = testClass.lineNumber(e.offset);
    endTest = testClass.lineNumber(e.end);


    var list = flow(e);

    if(list.isEmpty){
      testSmells.add(TestSmell(
          name: testSmellName,
          testName: testName,
          testClass: testClass,
          code: e.toSource(),
          codeMD5: Util.MD5(e.toSource()),
          codeTest: codeTest,
          codeTestMD5: Util.MD5(codeTest!),
          startTest: startTest,
          endTest: endTest,
          start: testClass.lineNumber(e.offset),
          end: testClass.lineNumber(e.end),
          collumnStart: testClass.columnNumber(e.offset),
          collumnEnd: testClass.columnNumber(e.end),
          offset: e.offset,
          endOffset: e.end
      ));
    }


    // if (e.toSource().contains("expect") == false && 
    // e.toSource().contains("expectLater") == false && 
    // e.toSource().contains("verify") == false &&
    // e.toSource().contains("assert") == false) {
    //   testSmells.add(TestSmell(
    //       name: testSmellName,
    //       testName: testName,
    //       testClass: testClass,
    //       code: e.toSource(),
    //       codeMD5: Util.MD5(e.toSource()),
    //       codeTest: codeTest,
    //       codeTestMD5: Util.MD5(codeTest!),
    //       startTest: startTest,
    //       endTest: endTest,
    //       start: testClass.lineNumber(e.offset),
    //       end: testClass.lineNumber(e.end),
    //       collumnStart: testClass.columnNumber(e.offset),
    //       collumnEnd: testClass.columnNumber(e.end),
    //       offset: e.offset,
    //       endOffset: e.end
    //   ));
    // }
    return testSmells;
  }

}

List<MethodInvocation> flow(AstNode e) {
  List<MethodInvocation> listMethods = List.empty(growable: true);

  if (e is MethodInvocation && (e.methodName.name == "expect" 
  || e.methodName.name == "expectLater" 
  || e.methodName.name == "verify" 
  || e.methodName.name == "assert" 
  )) {
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
