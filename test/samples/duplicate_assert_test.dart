import 'package:test/test.dart';

void main() {
  test("Duplicate Assert", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
  });


  test("Duplicate Assert", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 3, 4, reason: "Verificando o valor");
    expect(1 + 4, 5, reason: "Verificando o valor");
  });
}
