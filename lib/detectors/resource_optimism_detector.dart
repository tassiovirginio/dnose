import 'package:analyzer/dart/ast/ast.dart';
import 'package:dnose/detectors/abstract_detector.dart';

class ResourceOptimismDetector extends AbstractDetector {
  @override
  get testSmellName => "Resource Optimism";

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Check this MethodInvocation and do NOT recurse into children
    // (matching original behavior where MethodInvocation nodes stop recursion)
    if (node.toSource().replaceAll(" ", "").contains("File(")) {
      if ((node.toSource().contains("exists(") ||
              node.toSource().contains("existsSync(")) ==
          false) {
        testSmells.add(createSmell(node));
      }
    }
    // Deliberately do NOT call super.visitMethodInvocation(node)
    // to prevent recursing into child nodes (original behavior)
  }

  @override
  String getDescription() {
    return '''
    This smell occurs when a test method makes an optimistic assumption that the external resource 
    (e.g., File), utilized by the test method, exists.
    ''';
  }

  @override
  String getExample() {
    return '''
    test("DetectorResourceOptimism1", () {
    // ignore: unused_local_variable
    var file = File('file.txt');
  });
    ''';
  }
}
