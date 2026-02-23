import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class ExceptionHandlingDetector extends AbstractDetector {
  @override
  get testSmellName => "Exception Handling";

  @override
  void visitThrowExpression(ThrowExpression node) {
    testSmells.add(createSmell(node));
    super.visitThrowExpression(node);
  }

  @override
  void visitTryStatement(TryStatement node) {
    testSmells.add(createSmell(node));
    super.visitTryStatement(node);
  }

  @override
  String getDescription() {
    return '''
    This smell occurs when a test method explicitly a passing or failing of a test method 
    is dependent on the production method throwing an exception. Developers should utilize 
    JUnit's exception handling to automatically pass/fail the test instead of writing custom 
    exception handling code or throwing an exception.
    ''';
  }

  @override
  String getExample() {
    return '''
    void testFunction() {
    throw Exception("Erro");
  }

  test("Exception Handling1", () {
    //2
    try {
      throw Exception("Erro");
    } catch (e) {
      print(e);
    }
  });

  test("Exception Handling2", () {
    //1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    }
  });

  test("Exception Handling3", () {
    //1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    } finally {
      print("erro");
    }
  });
    ''';
  }
}
