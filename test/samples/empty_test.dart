import 'package:test/test.dart';

void main() {
  //teste vazio - Empty Test
  test("EmptyFixture1", () => {});
  test("EmptyFixture2", () => {     });
  test("EmptyFixture3", () {});
  test("EmptyFixture4", () {
    //comentário
  });
  test("EmptyFixture5", () {print("teste");
  expect((2+2), 4, reason: "Verificando o valor 123");});
}
