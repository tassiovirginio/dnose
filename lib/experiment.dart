// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/dart/analysis/utilities.dart';
// import 'package:analyzer/dart/analysis/features.dart';
//
// CompilationUnit ast = parseFile(
//     path:
//     '/home/tassio/Desenvolvimento/dart/dnose/test/oraculo_test.dart',
//     featureSet: FeatureSet.latestLanguageVersion())
//     .unit;
//
// void main(List<String> args) {
//   detectar01(ast);
// }
//
// int lineNumber(int offset) {
//   return ast.lineInfo.getLocation(offset).lineNumber;
// }
//
// void detectar01(var astnode) {
//   // if (astnode is ForElement || astnode is IfElement ) {
//   //   return;
//   // }
//   if (astnode is AstNode) {
//     String code = astnode.toSource();
//     print(astnode.runtimeType);
//     print(astnode.toSource());
//
//     // if (astnode is SetOrMapLiteral && astnode.toString().replaceAll(" ", "") == "{}"
//     // && astnode.parent!.parent!.parent!.parent!.childEntities.first.toString() == "test"){
//     if (astnode is Block
//         && astnode.parent is BlockFunctionBody
//         && astnode.parent!.parent is FunctionExpression
//     && astnode.parent!.parent!.parent!.parent is MethodInvocation
//     && astnode.parent!.parent!.parent!.parent!.childEntities.first.toString() == "test"
//     && astnode.toString().replaceAll(" ", "") == "{}"){
//
//       // int start = lineNumber(astnode.parent!.offset);
//       // int end = lineNumber(astnode.parent!.end);
//
//
//       print("Linha start: " + lineNumber(astnode.parent!.offset).toString());
//       print("Linha end: " + lineNumber(astnode.parent!.end).toString());
//       print("1 => " + astnode.childEntities.isEmpty.toString());
//       print("1 => " + astnode.toString());
//       print("1.1 => " + (astnode.toString().replaceAll(" ", "") == "{}").toString());
//       print("1 => " + astnode.runtimeType.toString());
//       print("2 => " + astnode.parent.toString());
//       print("2 => " + astnode.parent.runtimeType.toString());
//       print("3 => " + astnode.parent!.parent.toString());
//       print("3 => " + astnode.parent!.parent.runtimeType.toString());
//       print("4 => " + astnode.parent!.parent!.parent.toString());
//       print("4 => " + astnode.parent!.parent!.parent.runtimeType.toString());
//       print("5 => " + astnode.parent!.parent!.parent!.parent.toString());
//       print("5 => " + astnode.parent!.parent!.parent!.parent.runtimeType.toString());
//       print("6 => " + astnode.parent!.parent!.parent!.parent!.childEntities.first.toString());
//       // print("X => " + astnode.root.runtimeType.toString());
//     }
//
//     if (code.contains(RegExp("\bexpect\b|\breason:|\"\""))) {
//       print(astnode.runtimeType);
//       print(astnode.toSource());
//       // print(element.offset);
//           // print(element.end);
//           // print(element.length);
//           // print(element.toSource());
//           // print(element.toString());
//       print("---------------------------------------------------");
//     }
//   }
//
//   if (astnode.childEntities.isNotEmpty) {
//     astnode.childEntities.forEach((element) {
//       if (element is AstNode) {
//         detectar01(element);
//       }
//     });
//   }
// }
// //     astnode.childEntities.forEach((element) {

import 'dart:io';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:statistics/statistics.dart';

void main() async {
  var ns = [10, 20.0, 25, 30];
  print('ns: $ns');

  var mean = ns.mean;
  print('mean: $mean');

  var sdv = ns.standardDeviation;
  print('sdv: $sdv');

  var squares = ns.square;
  print('squares: $squares');

  // Statistics:

  var statistics = ns.statistics;

  print('Statistics.max: ${statistics.max}');
  print('Statistics.min: ${statistics.min}');
  print('Statistics.mean: ${statistics.mean}');
  print('Statistics.standardDeviation: ${statistics.standardDeviation}');
  print('Statistics.sum: ${statistics.sum}');
  print('Statistics.center: ${statistics.center}');
  print(
      'Statistics.median: ${statistics.median} -> ${statistics.medianLow} , ${statistics.medianHigh}');
  print('Statistics.squaresSum: ${statistics.squaresSum}');

  print('Statistics: $statistics');

  // CSV:

  var categories = <String, List<double?>>{
    'a': [10.0, 20.0, null],
    'b': [100.0, 200.0, 300.0]
  };

  var csv = categories.generateCSV();
  print('---');
  print('CSV:');
  print(csv);
}

Future<void> _example1() async {
  final llm = OpenAI(
    apiKey: 'sk-proj-ASl8dAsovhX3OAq6AGvGT3BlbkFJV9MB869wapMddLlRvLDa',
    defaultOptions: const OpenAIOptions(temperature: 0.9),
  );
  final LLMResult res = await llm.invoke(
    PromptValue.string('Tell me a joke'),
  );
  print(res);
}


String parseTest(FileSystemEntity fse) => fse.path;
