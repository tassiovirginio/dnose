import 'package:test/test.dart';

void main() {
  test("Magic Number", () => {expect(1 + 2, 3)}); //3

  test("Magic Number", () => {expect("3", "3")}); //2

  test("Magic Number", () => {expect("a3", "a3")}); //0

  test("Magic Number", () {
    //1
    print(123);
  });

  test("Magic Number", () {
    //1
    print("123");
  });

  test(
      "Magic Number", //3
      () => {
            for (int i = 0; i < 10; i++)
              {expect((1 + 1), 2, reason: "Verificando o valor")}
          });

  test(
      "Magic Number", //5
      () => {
            if (1 == 1)
              {
                for (int i = 0; i < 10; i++)
                  {expect((1 + 1), 2, reason: "Verificando o valor")}
              }
          });
}
