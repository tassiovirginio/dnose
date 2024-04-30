import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:teste01/detectors/TestClass.dart';
import 'package:teste01/detectors/TestSmell.dart';
import 'package:teste01/detectors/DetectorConditionalTestLogic.dart';
import 'package:teste01/detectors/DetectorPrintStatmentFixture.dart';
import 'package:teste01/detectors/DetectorSleepyFixture.dart';
import 'package:teste01/detectors/DetectorTestWithoutDescription.dart';
import 'package:teste01/detectors/DetectorMagicNumber.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

void main(List<String> args) {
  var ast = parseFile(
          path:
              '/home/tassio/Desenvolvimento/Dart/teste01/test/teste01_test.dart',
          featureSet: FeatureSet.latestLanguageVersion())
      .unit;

  detectar01(ast);
}

void detectar01(AstNode astnode) {
  // if (astnode is ForElement || astnode is IfElement ) {
  //   return;
  // }
  // if (astnode is VariableDeclaration) {
    print(astnode.runtimeType);
    print(astnode.toSource());
    print("---------------------------------------------------");
  // }
   
  if (astnode.childEntities.isNotEmpty) {
    astnode.childEntities.forEach((element) {
      if (element is AstNode) {
        detectar01(element);
      }
    });
  }
}
//     astnode.childEntities.forEach((element) {