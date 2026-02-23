import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

abstract class AbstractDetector extends RecursiveAstVisitor<void> {
  String get testSmellName;

  // State managed by detect() for use in visitor methods
  late List<TestSmell> testSmells;
  late TestClass testClass;
  late String testName;
  late String codeTest;
  late int startTest;
  late int endTest;

  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    this.testSmells = [];
    this.testClass = testClass;
    this.testName = testName;
    this.codeTest = e.toSource();
    this.startTest = testClass.lineNumber(e.offset);
    this.endTest = testClass.lineNumber(e.end);
    e.accept(this);
    return testSmells;
  }

  /// Helper to create a TestSmell with the current context.
  /// Uses flattened fields instead of TestClass reference for Isolate support.
  TestSmell createSmell(AstNode node) {
    return TestSmell(
      name: testSmellName,
      testName: testName,
      path: testClass.path,
      projectName: testClass.projectName,
      moduleAtual: testClass.moduleAtual,
      commit: testClass.commit,
      code: node.toSource(),
      codeMD5: Util.md5(node.toSource()),
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
    );
  }

  String getDescription();

  String getExample();
}
