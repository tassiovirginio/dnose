import 'dart:io';

import 'package:dnose/dnose_core.dart';
import 'package:dnose/models/test_class.dart';
import 'package:test/test.dart';

void main() {
  final dnoseCore = DNoseCore();
  final path = Directory.current.path;

  void verify({
    required String name,
    required int qtd,
    required String pathFile,
  }) {
    var (testSmells, testMetrics) = dnoseCore.scan(
      TestClass.test(File("$path$pathFile").path),
    );
    var list = testSmells.where((e) => e.name == name).toList();
    print("Found ${list.length} $name smells, expected $qtd");
    for (var smell in list) {
      print("  - ${smell.name}: ${smell.code}");
    }
    expect(
      list.length,
      qtd,
      reason: "Deveria encontrar $qtd test smells $name",
    );
  }

  test("Detect: Assertion Roullet", () {
    verify(
      name: "Assertion Roulette",
      qtd: 5,
      pathFile: "/test/samples/assertion_roulette_test.dart",
    );
  });

  test("Detect: Test Without Description", () {
    verify(
      name: "Test Without Description",
      qtd: 3,
      pathFile: "/test/samples/test_without_description_test.dart",
    );
  });

  test("Detect: Empty Test", () {
    verify(
      name: "Empty Test",
      qtd: 4,
      pathFile: "/test/samples/empty_test.dart",
    );
  });

  test("Detect: Unknown Test", () {
    verify(
      name: "Unknown Test",
      qtd: 3,
      pathFile: "/test/samples/unknown_test.dart",
    );
  });

  test("Detect: Conditional Test Logic", () {
    verify(
      name: "Conditional Test Logic",
      qtd: 10,
      pathFile: "/test/samples/conditional_test_logic_test.dart",
    );
  });

  test("Detect: Magic Number", () {
    verify(
      name: "Magic Number",
      qtd: 15,
      pathFile: "/test/samples/magic_number_test.dart",
    );
  });

  test("Detect: Duplicate Assert", () {
    verify(
      name: "Duplicate Assert",
      qtd: 10,
      pathFile: "/test/samples/duplicate_assert_test.dart",
    );
  });

  test("Detect: Resource Optimism", () {
    verify(
      name: "Resource Optimism",
      qtd: 1,
      pathFile: "/test/samples/resource_optimism_test.dart",
    );
  });

  test("Detect: Print Statment Fixture", () {
    verify(
      name: "Print Statment Fixture",
      qtd: 4,
      pathFile: "/test/samples/print_statment_fixture_test.dart",
    );
  });

  test("Detect: Sleepy Fixture", () {
    verify(
      name: "Sleepy Fixture",
      qtd: 2,
      pathFile: "/test/samples/sleepy_fixture_test.dart",
    );
  });

  test("Detect: Exception Handling", () {
    verify(
      name: "Exception Handling",
      qtd: 4,
      pathFile: "/test/samples/exception_handling_test.dart",
    );
  });

  test("Detect: Ignored Test", () {
    verify(
      name: "Ignored Test",
      qtd: 4,
      pathFile: "/test/samples/ignored_test.dart",
    );
  });

  test("Detect: Verbose Test", () {
    verify(
      name: "Verbose Test",
      qtd: 1,
      pathFile: "/test/samples/verbose_test.dart",
    );
  });

  test("Detect: Sensitive Equality", () {
    verify(
      name: "Sensitive Equality",
      qtd: 2,
      pathFile: "/test/samples/sensitive_equality_test.dart",
    );
  });

  test("Detect: Mystery Guest", () {
    verify(
      name: "Mystery Guest",
      qtd: 1,
      pathFile: "/test/samples/mystery_guest_test.dart",
    );
  });

  test("Detect: Redundant Assertion", () {
    verify(
      name: "Redundant Assertion",
      qtd: 17,
      pathFile: "/test/oracle/redundant_assertion_test.dart_",
    );
  });

}
