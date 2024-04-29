// List<TestSmell> testSmells = List.empty(growable: true);

// void detectCTL(ExpressionStatement e) {
//   String codigo = e.toSource();
//   if (codigo.contains("if") ||
//       codigo.contains("for") ||
//       codigo.contains("while")) {
//     testSmells.add(TestSmell("Conditional Test Logic"));
//     print("----------------------------");
//     print("-- Conditional Test Logic --");
//     print("----------------------------");
//   }
// }

// void detectPSF(ExpressionStatement e) {
//   String codigo = e.toSource();
//   if (codigo.contains("print")) {
//     testSmells.add(TestSmell("PrintStatmentFixture"));
//     print("----------------------------");
//     print("--- PrintStatmentFixture ---");
//     print("----------------------------");
//   }
// }

// void detectSleep(ExpressionStatement e) {
//   String codigo = e.toSource();
//   if (codigo.contains("sleep")) {
//     testSmells.add(TestSmell("SleepyFixture"));
//     print("----------------------------");
//     print("------- SleepyFixture ------");
//     print("----------------------------");
//   }
// }

// void testWithoutDescription(ExpressionStatement e) {
//   e.childEntities.forEach((element) {
//     if (element is MethodInvocation) {
//       element.childEntities.forEach((e2) {
//         if (e2 is ArgumentList) {
//           e2.childEntities.forEach((e3) {
//             if (e3 is SimpleStringLiteral) {
//               if (e3.value.trim().isEmpty) {
//                 TestSmell testSmell = TestSmell("TestWithoutDescription");
//                 testSmell.name = "TestWithoutDescription";
//                 testSmells.add(testSmell);
//                 print("----------------------------");
//                 print("-- TestWithoutDescription --");
//                 print("----------------------------");
//               }
//             }
//           });
//         }
//       });
//     }
//   });
// }

// void magicNumber(AstNode e) {
//   if (e is IntegerLiteral || e is DoubleLiteral) {
//     TestSmell testSmell = TestSmell("Magic Number");
//     testSmells.add(testSmell);
//     print("----------------------------");
//     print("------- Magic Number -------");
//     print("----------------------------");
//   } else {
//     e.childEntities.forEach((element) {
//       if (element is AstNode) {
//         magicNumber(element);
//       }
//     });
//   }
// }


// void magicNumber2(ExpressionStatement e) {
//   e.childEntities.forEach((element) {
//     if (element is MethodInvocation) {
//       element.childEntities.forEach((e2) {
//         if (e2 is ArgumentList) {
//           e2.childEntities.forEach((e3) {
//             if (e3 is FunctionExpression) {
//               e3.childEntities.forEach((element) {
//                 if (element is ExpressionFunctionBody) {
//                   element.childEntities.forEach((x5) {
//                     if (x5 is SetOrMapLiteral) {
//                       x5.childEntities.forEach((x6) {
//                         if (x6 is MethodInvocation) {
//                           x6.childEntities.forEach((x7) {
//                             if (x7 is ArgumentList) {
//                               x7.childEntities.forEach((x8) {
//                                 print("---> " +
//                                     x8.toString() +
//                                     " ---- " +
//                                     x8.runtimeType.toString());
//                               });
//                             }
//                           });
//                         }
//                       });
//                     }
//                   });
//                 }
//               });
//             }
//           });
//         }
//       });
//     }
//   });
// }


// void detectar01(AstNode astnode) {
//     astnode.childEntities.forEach((element) {
//       // print(element.runtimeType);

//       if (element is FunctionDeclaration) {
//         print("---------------  Achei uma função...");

//         element.childEntities.forEach((element) {
//           // print(element.runtimeType);
//           // print(element.toString());

//           if (element is FunctionExpression) {
//             element.childEntities.forEach((e) {
//               // print(e.runtimeType);
//               // print(e.toString());

//               if (e is BlockFunctionBody) {
//                 e.childEntities.forEach((e) {
//                   // print(e.runtimeType);
//                   // print(e.toString());

//                   if (e is Block) {
//                     e.childEntities.forEach((e) {
//                       // print(e.runtimeType);
//                       // print(e.toString());

//                       if (e is ExpressionStatement) {
//                         // print("->" + e.beginToken.toString());
//                         // print(e.beginToken.type);

//                         if (e.beginToken.toString() == "test" &&
//                             e.beginToken.type == TokenType.IDENTIFIER) {
//                           print("Achei um Teste...");
//                           print(e.toSource());
//                           print(e.offset);
//                           // detectCTL(e.toSource());
//                           // detectPSF(e.toSource());
//                           // detectSleep(e.toSource());
//                         }

//                         // e.childEntities.forEach((e) {
//                         //   print(e.runtimeType);
//                         //   print(e.toString());
//                         // });
//                       }
//                     });
//                   }
//                 });
//               }
//             });
//           }
//         });
//       }
//     });
//   }