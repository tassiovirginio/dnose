import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dnose/detectors/abstract_detector.dart';
import 'package:dnose/models/test_class.dart';
import 'package:dnose/models/test_smell.dart';
import 'package:dnose/utils/util.dart';

class ConditionalTestLogicDetector implements AbstractDetector {
  @override
  get testSmellName => "Conditional Test Logic";

  @override
  List<TestSmell> detect(
    ExpressionStatement e,
    TestClass testClass,
    String testName,
  ) {
    final visitor = _ConditionalTestLogicVisitor(
      testClass: testClass,
      testName: testName,
      testSmellName: testSmellName,
      codeTest: e.toSource(),
      startTest: testClass.lineNumber(e.offset),
      endTest: testClass.lineNumber(e.end),
    );
    e.accept(visitor);
    return visitor.testSmells;
  }

  @override
  String getDescription() {
    return '''
        Test methods need to be simple and execute all statements in the production method. 
        Conditions within the test method will alter the behavior of the test and its expected output, 
        and would lead to situations where the test fails to detect defects in the production method 
        since test statements were not executed as a condition was not met. Furthermore, 
        conditional code within a test method negatively impacts the ease of comprehension by developers.
        ''';
  }

  @override
  String getExample() {
    return '''
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
        ''';
  }
}

class _ConditionalTestLogicVisitor extends RecursiveAstVisitor<void> {
  final TestClass testClass;
  final String testName;
  final String testSmellName;
  final String codeTest;
  final int startTest;
  final int endTest;

  final List<TestSmell> testSmells = [];

  _ConditionalTestLogicVisitor({
    required this.testClass,
    required this.testName,
    required this.testSmellName,
    required this.codeTest,
    required this.startTest,
    required this.endTest,
  });

  @override
  void visitForStatement(ForStatement node) {
    _addSmell(node);
    super.visitForStatement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    _addSmell(node);
    super.visitIfStatement(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _addSmell(node);
    super.visitWhileStatement(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _addSmell(node);
    super.visitSwitchStatement(node);
  }

  @override
  void visitForElement(ForElement node) {
    _addSmell(node);
    super.visitForElement(node);
  }

  @override
  void visitIfElement(IfElement node) {
    _addSmell(node);
    super.visitIfElement(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == "forEach") {
      _addSmell(node);
    }
    super.visitSimpleIdentifier(node);
  }

  void _addSmell(AstNode node) {
    testSmells.add(
      TestSmell(
        name: testSmellName,
        testName: testName,
        testClass: testClass,
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
      ),
    );
  }
}
