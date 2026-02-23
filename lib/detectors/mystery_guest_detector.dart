import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class MysteryGuestDetector extends AbstractDetector {
  @override
  get testSmellName => "Mystery Guest";

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Detect file reads like File('path').readAsStringSync() or similar
    if (node.methodName.name == 'readAsStringSync' &&
        node.target is MethodInvocation &&
        (node.target as MethodInvocation).methodName.name == 'File') {
      // Check if the file path is a string literal (not a variable)
      var fileArgs = (node.target as MethodInvocation).argumentList.arguments;
      if (fileArgs.isNotEmpty && fileArgs.first is SimpleStringLiteral) {
        testSmells.add(createSmell(node));
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  String getDescription() {
    return '''
      Occurs when a test depends on external data or states that are not explicitly visible in the test code.
      This creates implicit dependencies that make the test behavior difficult to understand and maintain.
      Examples include reading from files, databases, or external configurations without clear setup.
      ''';
  }

  @override
  String getExample() {
    return '''
      test('Gift model test', () {
        final file = File('json/gift_test.json').readAsStringSync();
        final gifts = Gift.fromJson(jsonDecode(file) as Map<String, dynamic>);

        expect(gifts.id, 999);
      });

      // Better approach:
      test('Gift model test', () {
        final testData = '{"id": 999, "name": "Test Gift"}';
        final gifts = Gift.fromJson(jsonDecode(testData) as Map<String, dynamic>);

        expect(gifts.id, 999);
      });
      ''';
  }
}
