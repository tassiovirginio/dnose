import 'package:test/test.dart';

void main() {
  test("AssertionRoulet", () {
    // 1 x 2 (1)
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3,
        reason: ""); //Melhorar a detecção para pegar esse tipo de erro
    expect(1 + 2, 3);
  });

  test("AssertionRoulet", () {
    // 0 x 3 (0)
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
  });

  test("AssertionRoulet", () {
    // 2 x 1 (1)
    expect(1 + 2, 3);
    expect(1 + 2, 3,
        reason: ""); //Melhorar a detecção para pegar esse tipo de erro
    expect(1 + 2, 3);
  });

  test("AssertionRoulet", () {
    // 1 x 1 (0)
    expect(1 + 2, 3);
    expect(1 + 2, 3,
        reason: ""); //Melhorar a detecção para pegar esse tipo de erro
  });

  test("AssertionRoulet", () {
    // 2 x 0 (1)
    expect(1 + 2, 3);
    expect(1 + 2, 3);
  });

  test("AssertionRoulet", () {
    // 3 x 0 (2)
    expect(1 + 2, 3);
    expect(1 + 2, 3);
    expect(1 + 2, 3);
  });

  test("AssertionRoulet", () {
    // 1 x 0
    expect(1 + 2, 3);
  });

  soma(a, b) {
    return a + b;
  }

  test("Verificar Soma - 1 + 1", () {
    var valor = soma(1, 1);
    expect(valor, 2);
  });

  test("Verificar Soma - 1 + 2", () {
    var valor = soma(1, 2);
    expect(valor, 3);
  });
}
