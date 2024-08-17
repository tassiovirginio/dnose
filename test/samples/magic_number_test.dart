import 'package:test/test.dart';

void main() {
  test("Magic Number", () => {expect(1 + 2, 3)});

  test(
      "Magic Number",
      () =>{
            for (int i = 0; i < 10; i++)
              {expect((1 + 1), 2, reason: "Verificando o valor")}
          });
}
