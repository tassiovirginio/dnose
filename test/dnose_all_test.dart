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
      qtd: 6,
      pathFile: "/test/oracle/mystery_guest_test.dart_",
    );
  });

  test("Detect: Redundant Assertion", () {
    verify(
      name: "Redundant Assertion",
      qtd: 17,
      pathFile: "/test/oracle/redundant_assertion_test.dart_",
    );
  });

  test("Detect: Expected Resolution Omission", () {
    verify(
      name: "Expected Resolution Omission",
      qtd: 6,
      pathFile: "/test/oracle/expected_resolution_omission_test.dart_",
    );
  });

  test("Detect: Default Test", () {
    verify(
      name: "Default Test",
      qtd: 4,
      pathFile: "/test/oracle/default_test.dart_",
    );
  });

  test("Detect: Residual State", () {
    verify(
      name: "Residual State",
      qtd: 5,
      pathFile: "/test/oracle/residual_state_test.dart_",
    );
  });

  test("Detect: Eager Test", () {
    verify(
      name: "Eager Test",
      qtd: 7,
      pathFile: "/test/oracle/eager_test.dart_",
    );
  });

  test("Detect: Lazy Test", () {
    verify(
      name: "Lazy Test",
      qtd: 11,
      pathFile: "/test/oracle/lazy_test.dart_",
    );
  });

  test("Detect: Widget Setup", () {
    verify(
      name: "Widget Setup",
      qtd: 6,
      pathFile: "/test/oracle/widget_setup_test.dart_",
    );
  });

  test("Detect: Dependent Test", () {
    verify(
      name: "Dependent Test",
      qtd: 2,
      pathFile: "/test/oracle/dependent_test.dart_",
    );
  });

  test("Detect: Constructor Initialization", () {
    verify(
      name: "Constructor Initialization",
      qtd: 4,
      pathFile: "/test/samples/constructor_initialization_test.dart",
    );
  });

  // ============================================
  // NEGATIVE TESTS (Clean code - expect 0 smells)
  // ============================================

  test("Negative: ERO Clean (expect 0)", () {
    verify(
      name: "Expected Resolution Omission",
      qtd: 0,
      pathFile: "/test/oracle/negative/ero_clean_test.dart_",
    );
  });

  test("Negative: Residual State Clean (expect 0)", () {
    verify(
      name: "Residual State",
      qtd: 0,
      pathFile: "/test/oracle/negative/residual_state_clean_test.dart_",
    );
  });

  test("Negative: Mystery Guest Clean (expect 0)", () {
    verify(
      name: "Mystery Guest",
      qtd: 0,
      pathFile: "/test/oracle/negative/mystery_guest_clean_test.dart_",
    );
  });

  test("Negative: Default Test Clean (expect 0)", () {
    verify(
      name: "Default Test",
      qtd: 0,
      pathFile: "/test/oracle/negative/default_test_clean_test.dart_",
    );
  });

  test("Negative: Dependent Test Clean (expect 0)", () {
    verify(
      name: "Dependent Test",
      qtd: 0,
      pathFile: "/test/oracle/negative/dependent_test_clean_test.dart_",
    );
  });

  test("Negative: Eager Test Clean (expect 0)", () {
    verify(
      name: "Eager Test",
      qtd: 0,
      pathFile: "/test/oracle/negative/eager_test_clean_test.dart_",
    );
  });

  test("Negative: Lazy Test Clean (expect 0)", () {
    verify(
      name: "Lazy Test",
      qtd: 0,
      pathFile: "/test/oracle/negative/lazy_test_clean_test.dart_",
    );
  });

  test("Negative: Redundant Assertion Clean (expect 0)", () {
    verify(
      name: "Redundant Assertion",
      qtd: 0,
      pathFile: "/test/oracle/negative/redundant_assertion_clean_test.dart_",
    );
  });

  test("Negative: Widget Setup Clean (expect 0)", () {
    verify(
      name: "Widget Setup",
      qtd: 0,
      pathFile: "/test/oracle/negative/widget_setup_clean_test.dart_",
    );
  });
}
