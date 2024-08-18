import 'dart:io';

import 'package:dnose/dnose.dart';
import 'package:dnose/models/test_class.dart';
import 'package:test/test.dart';

void main() {
  final dnose = DNose();
  final path = Directory.current.path;

  void verify(
      {required String name, required int qtd, required String pathFile}) {
    var (testSmells, testMetrics) =
        dnose.scan(TestClass.test(File("$path$pathFile").path));
    var list = testSmells.where((e) => e.name == name).toList();
    expect(list.length, qtd,
        reason: "Deveria encontrar $qtd test smells $name");
  }

  test("Detect: Assertion Roulet", () {
    verify(
        name: "Assertion Roulette",
        qtd: 3,
        pathFile: "/test/samples/assertion_roulette_test.dart");
  });

  test("Detect: Test Without Description", () {
    verify(
        name: "Test Without Description",
        qtd: 3,
        pathFile: "/test/samples/test_without_description_test.dart");
  });

  test("Detect: Empty Test", () {
    verify(
        name: "Empty Test", qtd: 3, pathFile: "/test/samples/empty_test.dart");
  });

  test("Detect: Unknown Test", () {
    verify(
        name: "Unknown Test",
        qtd: 1,
        pathFile: "/test/samples/unknown_test.dart");
  });

  test("Detect: Conditional Test Logic", () {
    verify(
        name: "Conditional Test Logic",
        qtd: 7,
        pathFile: "/test/samples/conditional_test_logic_test.dart");
  });

  test("Detect: Magic Number", () {
    verify(
        name: "Magic Number",
        qtd: 10,
        pathFile: "/test/samples/magic_number_test.dart");
  });

  test("Detect: Duplicate Assert", () {
    verify(
        name: "Duplicate Assert",
        qtd: 1,
        pathFile: "/test/samples/duplicate_assert_test.dart");
  });

  test("Detect: Resource Optimism", () {
    verify(
        name: "Resource Optimism",
        qtd: 1,
        pathFile: "/test/samples/resource_optimism_test.dart");
  });

  test("Detect: Print Statment Fixture", () {
    verify(
        name: "Print Statment Fixture",
        qtd: 1,
        pathFile: "/test/samples/print_statment_fixture_test.dart");
  });

  test("Detect: Sleepy Fixture", () {
    verify(
        name: "Sleepy Fixture",
        qtd: 1,
        pathFile: "/test/samples/sleepy_fixture_test.dart");
  });

  test("Detect: Exception Handling", () {
    verify(
        name: "Exception Handling",
        qtd: 3,
        pathFile: "/test/samples/exception_handling_test.dart");
  });

  test("Detect: Ignored Test", () {
    verify(
        name: "Ignored Test",
        qtd: 1,
        pathFile: "/test/samples/ignored_test.dart");
  });

  test("Detect: Verbose Test", () {
    verify(
        name: "Verbose Test",
        qtd: 1,
        pathFile: "/test/samples/verbose_test.dart");
  });
}
