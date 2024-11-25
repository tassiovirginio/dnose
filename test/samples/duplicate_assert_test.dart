import 'package:test/test.dart';

void main() {
  test("Duplicate Assert", () { // 2
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
  });


  test("Duplicate Assert", () { // 0
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 3, 4, reason: "Verificando o valor");
    expect(1 + 4, 5, reason: "Verificando o valor");
  });


  test("Duplicate Assert", () { // 0
    expect(1 + 2, 3, reason: "Verificando o valor 123");
    expect(1 + 2, 3, reason: "Verificando o valor 321");
    expect(1 + 2, 3, reason: "Verificando o valor 111");
  });

  test("Duplicate Assert", () { // 1
    expect(1 + 3, 4, reason: "Verificando o valor 123");
    expect(1 + 3, 4, reason: "Verificando o valor 321");
    expect(1 + 3, 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert", () { // 1
    expect(1 + 3, 4, reason: "Verificando o valor 123");
    expect(1 + 3, 4, reason: "Verificando o valor 321");
    expect(1 + 3, 4, reason: "Verificando o valor 123");
  });


}
