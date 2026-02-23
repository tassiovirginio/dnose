import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class MagicNumberDetector extends AbstractDetector {
  @override
  String get testSmellName => "Magic Number";

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    // Skip for loop declarations - don't recurse into them
    return;
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    // Skip named expressions - don't recurse into them
    return;
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    testSmells.add(createSmell(node));
    super.visitIntegerLiteral(node);
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    testSmells.add(createSmell(node));
    super.visitDoubleLiteral(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.toSource().replaceAll("\"", "").contains(RegExp(r'^\d+$'))) {
      testSmells.add(createSmell(node));
    }
    super.visitSimpleStringLiteral(node);
  }

  @override
  String getDescription() {
    return '''
    Occurs when assert statements in a test method contain numeric literals (i.e., magic numbers) 
    as parameters. Magic numbers do not indicate the meaning/purpose of the number. Hence, they 
    should be replaced with constants or variables, thereby providing a descriptive name for the input.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Magic Number1", () => {expect(1 + 2, 3)}); //3

  test("Magic Number2", () => {expect("3", "3")}); //2

  test("Magic Number4", () {
    //1
    print(123);
  });

  test("Magic Number5", () {
    //1
    print("123");
  });
    ''';
  }
}
