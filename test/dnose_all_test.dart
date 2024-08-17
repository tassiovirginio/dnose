import 'dart:io';

import 'package:dnose/dnose.dart';
import 'package:dnose/main.dart';
import 'package:dnose/models/test_class.dart';
import 'package:test/test.dart';

void main() {
  DNose dnose = DNose();

  test("Assertion Roulet Detect", () {
    File file = File(
        "${Directory.current.path}/test/assertion_roulette_test.dart");
    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Assertion Roulette").toList();
      expect(lista.length, 3, reason: "Deveria encontrar 3 test smells do tipo Assertion Roulette");
    }
  });
}
