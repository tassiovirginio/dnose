import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class SensitiveEqualityDetector extends AbstractDetector {
  @override
  get testSmellName => "Sensitive Equality";

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.childEntities.first is SimpleIdentifier &&
        node.childEntities.first.toString().trim() == "expect" &&
        node.childEntities.last.toString().contains(".toString()")) {
      testSmells.add(createSmell(node));
    }
    super.visitMethodInvocation(node);
  }

  @override
  String getDescription() {
    return '''
    Occurs when the toString method is used within a test method. Test methods verify 
    objects by invoking the default toString() method of the object and comparing the output 
    against an specific string. Changes to the implementation of toString() might result in 
    failure. The correct approach is to implement a custom method within the object to perform this
     comparison.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("Sensitive Equality1", () {
    String test = "teste";
    expect("teste", test.toString());
  });

  test("Sensitive Equality2", () {
    String test = "teste";
    expect("teste", test.toString());
  });

  test("Sensitive Equality3", () {
    String test = "teste";
    expect("teste", test.toLowerCase());
  });

  test("Sensitive Equality4", () {
    String test = "TESTE";
    expect("TESTE", test.toUpperCase());
  });
    ''';
  }
}
