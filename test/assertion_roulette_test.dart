import 'package:test/test.dart';

void main() {
  test("AssertionRoulet", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "");
    expect(1 + 2, 3);
  });
}
