import 'package:test/test.dart';

void main() {
  test("AssertionRoulet", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "");//Melhorar a detecção para pegar esse tipo de erro
    expect(1 + 2, 3);
  });


  test("AssertionRoulet", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
  });

  test("AssertionRoulet", () {
    expect(1 + 2, 3);
    expect(1 + 2, 3, reason: "");//Melhorar a detecção para pegar esse tipo de erro
    expect(1 + 2, 3);
  });
}
