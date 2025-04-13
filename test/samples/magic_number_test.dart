import 'package:test/test.dart';

void main() {
  test("Magic Number1", () => {expect(1 + 2, 3)}); //3

  test("Magic Number2", () => {expect("3", "3")}); //2

  test("Magic Number3", () => {expect("a3", "a3")}); //0

  test("Magic Number4", () {
    //1
    print(123);
  });

  test("Magic Number5", () {
    //1
    print("123");
  });

  test(
      "Magic Number6", //3
      () => {
            for (int i = 0; i < 10; i++)
              {expect((1 + 1), 2, reason: "Verificando o valor")}
          });

  test(
      "Magic Number7", //5
      () => {
            if (1 == 1)
              {
                for (int i = 0; i < 10; i++)
                  {expect((1 + 1), 2, reason: "Verificando o valor")}
              }
          });
}
