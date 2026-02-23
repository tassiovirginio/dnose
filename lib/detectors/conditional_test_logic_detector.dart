import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class ConditionalTestLogicDetector extends AbstractDetector {
  @override
  get testSmellName => "Conditional Test Logic";

  @override
  void visitForStatement(ForStatement node) {
    testSmells.add(createSmell(node));
    super.visitForStatement(node);
  }

  @override
  void visitForElement(ForElement node) {
    testSmells.add(createSmell(node));
    super.visitForElement(node);
  }

  @override
  void visitIfStatement(IfStatement node) {
    testSmells.add(createSmell(node));
    super.visitIfStatement(node);
  }

  @override
  void visitIfElement(IfElement node) {
    testSmells.add(createSmell(node));
    super.visitIfElement(node);
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    testSmells.add(createSmell(node));
    super.visitWhileStatement(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    testSmells.add(createSmell(node));
    super.visitSwitchStatement(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == "forEach") {
      testSmells.add(createSmell(node));
    }
    super.visitSimpleIdentifier(node);
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
