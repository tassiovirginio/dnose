import 'package:dnose/models/test_class.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:analyzer/dart/ast/ast.dart';

class VerboseTestDetector implements AbstractDetector{
  @override
  get testSmellName => "Verbose Test";

  final VALUE_MAX_LINES_VERBOSE = 30;

  List<TestSmell> testSmells = List.empty(growable: true);

  List<TestSmell> detect(ExpressionStatement e, TestClass testClass, String testName) {
    _detect(e as AstNode, testClass, testName);
    return testSmells;
  }

  void _detect(AstNode e, TestClass testClass, String testName) {

    if (e is SimpleIdentifier && e.toString() == "test" && e.parent is MethodInvocation) {

      int start = lineNumber(e.root as CompilationUnit, e.parent!.offset);
      int end = lineNumber(e.root as CompilationUnit, e.parent!.end);

      if(end - start > VALUE_MAX_LINES_VERBOSE){
        testSmells.add(TestSmell(
            testSmellName, testName, testClass, code: e.toSource(),
            start: testClass.lineNumber(e.parent!.offset),
            end: testClass.lineNumber(e.parent!.end)));
      }

    }else {
      e.childEntities.forEach((element) {
        if (element is AstNode) {
          _detect(element, testClass, testName);
        }
      });
    }
  }

  int lineNumber(CompilationUnit cu ,int offset) {
    return cu.lineInfo.getLocation(offset).lineNumber;
  }
}