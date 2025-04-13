import 'package:test/test.dart';

void main() {
  test("Sensitive Equality1", () {
    String test = "teste";
    expect("teste", test.toString());
  });


  test("Sensitive Equality2", () {
    String test = "teste";
    expect("teste", test.toString());
  });


  test("Sensitive Equality3", () {
    String test = "teste";
    expect("teste", test.toLowerCase());
  });

  test("Sensitive Equality4", () {
    String test = "TESTE";
    expect("TESTE", test.toUpperCase());
  });
}
