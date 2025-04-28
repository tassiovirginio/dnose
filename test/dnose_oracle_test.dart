import 'dart:io';

import 'package:dnose/dnose_core.dart';
import 'package:dnose/models/test_class.dart';
import 'package:test/test.dart';

void main() {
  final dnose = DNoseCore();
  final path = Directory.current.path;

  void verify(
      {required String name, required int qtd, required String pathFile}) {
    var (testSmells, testMetrics) =
        dnose.scan(TestClass.test(File("$path$pathFile").path));
    var list = testSmells.where((e) => e.name == name).toList();
    expect(list.length, qtd,
        reason: "Deveria encontrar $qtd test smells $name");
  }

  test("Detect: Assertion Roullet", () {
    verify(
        name: "Assertion Roulette",
        qtd: 25,
        pathFile: "/test/oracle/assertion_roulette_test.dart_");
  });

  test("Detect: Test Without Description", () {
    verify(
        name: "Test Without Description",
        qtd: 5,
        pathFile: "/test/oracle/test_without_description_test.dart_");
  });

  test("Detect: Empty Test", () {
    verify(
        name: "Empty Test", qtd: 6, pathFile: "/test/oracle/empty_test.dart_");
  });

  test("Detect: Unknown Test", () {
    verify(
        name: "Unknown Test",
        qtd: 8,
        pathFile: "/test/oracle/unknown_test.dart_");
  });

  test("Detect: Conditional Test Logic", () {
    verify(
        name: "Conditional Test Logic",
        qtd: 7,
        pathFile: "/test/oracle/conditional_test_logic_test.dart_");
  });

  test("Detect: Magic Number", () {
    verify(
        name: "Magic Number",
        qtd: 26,
        pathFile: "/test/oracle/magic_number_test.dart_");
  });

  // test("Detect: Duplicate Assert", () {
  //   verify(
  //       name: "Duplicate Assert",
  //       qtd: 4,
  //       pathFile: "/test/oracle/duplicate_assert_test.dart");
  // });

  // test("Detect: Resource Optimism", () {
  //   verify(
  //       name: "Resource Optimism",
  //       qtd: 1,
  //       pathFile: "/test/oracle/resource_optimism_test.dart");
  // });

  // test("Detect: Print Statment Fixture", () {
  //   verify(
  //       name: "Print Statment Fixture",
  //       qtd: 4,
  //       pathFile: "/test/oracle/print_statment_fixture_test.dart");
  // });

  // test("Detect: Sleepy Fixture", () {
  //   verify(
  //       name: "Sleepy Fixture",
  //       qtd: 2,
  //       pathFile: "/test/oracle/sleepy_fixture_test.dart");
  // });

  // test("Detect: Exception Handling", () {
  //   verify(
  //       name: "Exception Handling",
  //       qtd: 5,
  //       pathFile: "/test/oracle/exception_handling_test.dart");
  // });

  // test("Detect: Ignored Test", () {
  //   verify(
  //       name: "Ignored Test",
  //       qtd: 1,
  //       pathFile: "/test/oracle/ignored_test.dart");
  // });

  // test("Detect: Verbose Test", () {
  //   verify(
  //       name: "Verbose Test",
  //       qtd: 1,
  //       pathFile: "/test/oracle/verbose_test.dart");
  // });


  // test("Detect: Sensitive Equality", () {
  //   verify(
  //       name: "Sensitive Equality",
  //       qtd: 2,
  //       pathFile: "/test/oracle/sensitive_equality_test.dart");
  // });
}
