import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class EmptyTestDetector extends AbstractDetector {
  @override
  get testSmellName => "Empty Test";

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is ArgumentList &&
        node.parent!.parent is MethodInvocation &&
        node.parent!.parent!.parent is ExpressionStatement &&
        node.parent!.parent!.parent!.parent is Block &&
        node.parent!.parent!.childEntities.first.toString() == "test" &&
        (node.toString().replaceAll(" ", "") == "()=>{}" ||
            node.toString().replaceAll(" ", "") == "{}" ||
            node.toString().replaceAll(" ", "") == "(){}")) {
      testSmells.add(createSmell(node));
    }
    super.visitFunctionExpression(node);
  }

  @override
  String getDescription() {
    return '''
        Occurs when a test method does not contain executable statements. Such methods are 
        possibly created for debugging purposes and then forgotten about or contains commented 
        out code. An empty test can be considered problematic and more dangerous than not having 
        a test case at all since JUnit will indicate that the test passes even if there are no 
        executable statements present in the method body. As such, developers introducing 
        behavior-breaking changes into production class, 
        will not be notified of the alternated outcomes as JUnit will report the test as passing.
        ''';
  }

  @override
  String getExample() {
    return '''
        test("EmptyFixture1", () => {});
  test("EmptyFixture2", () => {     });
  test("EmptyFixture3", () {});
  test("EmptyFixture4", () {
    //comentário
  });
        ''';
  }
}
