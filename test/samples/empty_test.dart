import 'package:test/test.dart';

void main() {
  //teste vazio - Empty Test
  test("EmptyFixture", () => {});
  test("EmptyFixture", () => {     });
  test("EmptyFixture", () {});
  test("EmptyFixture", () {
    //comentário
  });
  test("EmptyFixture", () {print("teste");});
}
