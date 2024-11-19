import 'package:test/test.dart';

void main() {
  test("Sensitive Equality", () {
    String test = "teste";
    expect("teste", test.toString());
  });


  test("Sensitive Equality", () {
    String test = "teste";
    expect("teste", test.toString());
  });


  test("Sensitive Equality", () {
    String test = "teste";
    expect("teste", test.toLowerCase());
  });

  test("Sensitive Equality", () {
    String test = "TESTE";
    expect("TESTE", test.toUpperCase());
  });
}
