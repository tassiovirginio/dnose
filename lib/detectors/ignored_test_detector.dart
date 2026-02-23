import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class IgnoredTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Ignored Test";

  @override
  void visitNamedExpression(NamedExpression node) {
    if (node.parent is ArgumentList &&
        (node.toString().contains("skip: true") ||
            node.toString().contains("skip:true") ||
            node.toString().contains("skip: \""))) {
      if (node.childEntities.elementAt(0) is Label &&
          node.childEntities.elementAt(0).toString() == "skip:" &&
          node.childEntities.elementAt(1).toString() != "false") {
        testSmells.add(createSmell(node));
        // Don't recurse into this node (preserving original else-branch behavior)
        return;
      }
    }
    super.visitNamedExpression(node);
  }

  @override
  String getDescription() {
    return '''
    Testing in Dart offers developers the ability to suppress the execution of test methods. 
    However, these ignored test methods result in overhead, as they add unnecessary cost regarding 
    compilation time and increase code complexity and comprehension difficulty.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Some Test1", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:        true);

  test("Some Test2", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "Message Ignore");


  test("Some Test3", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "");

  test("Some Test4", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "     ");
    ''';
  }
}
