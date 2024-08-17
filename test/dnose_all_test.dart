import 'dart:io';

import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:test/test.dart';

void main() {
  DNose dnose = DNose();

  test("Detect: Assertion Roulet", () {
    File file = File(
        "${Directory.current.path}/test/samples/assertion_roulette_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista =
          testSmells.where((e) => e.name == "Assertion Roulette").toList();
      expect(lista.length, 3,
          reason: "Deveria encontrar 3 test smells do tipo Assertion Roulette");
    }
  });

  test("Detect: Test Without Description", () {
    File file = File(
        "${Directory.current.path}/test/samples/test_without_description_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells
          .where((e) => e.name == "Test Without Description")
          .toList();
      expect(lista.length, 3,
          reason:
              "Deveria encontrar 3 test smells do tipo Test Without Description");
    }
  });

  test("Detect: Empty Test", () {
    File file = File("${Directory.current.path}/test/samples/empty_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Empty Test").toList();
      expect(lista.length, 3,
          reason: "Deveria encontrar 3 test smells do tipo Empty Test");
    }
  });

  test("Detect: Unknown Test", () {
    File file =
        File("${Directory.current.path}/test/samples/unknown_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Unknown Test").toList();
      expect(lista.length, 1,
          reason: "Deveria encontrar 1 test smells do tipo Unknown Test");
    }
  });

  test("Detect: Conditional Test Logic", () {
    File file = File(
        "${Directory.current.path}/test/samples/conditional_test_logic_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista =
          testSmells.where((e) => e.name == "Conditional Test Logic").toList();
      expect(lista.length, 7,
          reason:
              "Deveria encontrar 7 test smells do tipo Conditional Test Logic");
    }
  });

  test("Detect: Magic Number", () {
    File file =
        File("${Directory.current.path}/test/samples/magic_number_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Magic Number").toList();
      expect(lista.length, 6,
          reason: "Deveria encontrar 6 test smells do tipo Magic Number");
    }
  });

  test("Detect: Duplicate Assert", () {
    File file = File(
        "${Directory.current.path}/test/samples/duplicate_assert_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista =
          testSmells.where((e) => e.name == "Duplicate Assert").toList();
      expect(lista.length, 1,
          reason: "Deveria encontrar 1 test smells do tipo Duplicate Assert");
    }
  });

  test("Detect: Resource Optimism", () {
    File file = File(
        "${Directory.current.path}/test/samples/resource_optimism_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista =
          testSmells.where((e) => e.name == "Resource Optimism").toList();
      expect(lista.length, 1,
          reason: "Deveria encontrar 1 test smells do tipo Resource Optimism");
    }
  });

  test("Detect: Print Statment Fixture", () {
    File file = File(
        "${Directory.current.path}/test/samples/print_statment_fixture_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista =
          testSmells.where((e) => e.name == "Print Statment Fixture").toList();
      expect(lista.length, 1,
          reason:
              "Deveria encontrar 1 test smells do tipo Print Statment Fixture");
    }
  });

  test("Detect: Sleepy Fixture", () {
    File file =
        File("${Directory.current.path}/test/samples/sleepy_fixture_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Sleepy Fixture").toList();
      expect(lista.length, 1,
          reason: "Deveria encontrar 1 test smells do tipo Sleepy Fixture");
    }
  });

  test("Detect: Exception Handling", () {
    File file = File(
        "${Directory.current.path}/test/samples/exception_handling_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista =
          testSmells.where((e) => e.name == "Exception Handling").toList();
      expect(lista.length, 3,
          reason: "Deveria encontrar 3 test smells do tipo Exception Handling");
    }
  });

  test("Detect: Ignored Test", () {
    File file =
        File("${Directory.current.path}/test/samples/ignored_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Ignored Test").toList();
      expect(lista.length, 1,
          reason: "Deveria encontrar 1 test smells do tipo Ignored Test");
    }
  });


  test("Detect: Verbose Test", () {
    File file =
        File("${Directory.current.path}/test/samples/verbose_test.dart");

    if (file.path.endsWith("_test.dart") == true) {
      TestClass testClass = TestClass(
          commit: "", path: file.path, moduleAtual: "", projectName: "");
      var (testSmells, testMetrics) = dnose.scan(testClass);
      var lista = testSmells.where((e) => e.name == "Verbose Test").toList();
      expect(lista.length, 1,
          reason: "Deveria encontrar 1 test smells do tipo Verbose Test");
    }
  });
}
