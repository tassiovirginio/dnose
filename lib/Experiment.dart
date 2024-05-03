import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dnose/detectors/TestClass.dart';
import 'package:dnose/detectors/TestSmell.dart';
import 'package:dnose/detectors/DetectorConditionalTestLogic.dart';
import 'package:dnose/detectors/DetectorPrintStatmentFixture.dart';
import 'package:dnose/detectors/DetectorSleepyFixture.dart';
import 'package:dnose/detectors/DetectorTestWithoutDescription.dart';
import 'package:dnose/detectors/DetectorMagicNumber.dart';
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
  if (astnode is MethodInvocation) {
    String code = astnode.toSource();

    if (code.contains(RegExp("\bexpect\b|\breason:|\"\""))) {
      print(astnode.runtimeType);
      print(astnode.toSource());
      // print(element.offset);
          // print(element.end);
          // print(element.length);
          // print(element.toSource());
          // print(element.toString());
      print("---------------------------------------------------");
    }
  }

  if (astnode.childEntities.isNotEmpty) {
    astnode.childEntities.forEach((element) {
      if (element is AstNode) {
        detectar01(element);
      }
    });
  }
}
//     astnode.childEntities.forEach((element) {