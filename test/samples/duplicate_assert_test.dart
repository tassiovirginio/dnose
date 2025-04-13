import 'package:test/test.dart';

void main() {
  test("Duplicate Assert1", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
  });


  test("Duplicate Assert2", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(2,2), 4, reason: "Verificando o valor");
    expect(sum(2,3), 5, reason: "Verificando o valor");
  });


  test("Duplicate Assert3", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor 123");
    expect(sum(1,2), 3, reason: "Verificando o valor 321");
    expect(sum(1,2), 3, reason: "Verificando o valor 111");
  });

  test("Duplicate Assert4", () { // 1
    expect(sum(1,3), 4, reason: "Verificando o valor 123");
    expect(sum(1,3), 4, reason: "Verificando o valor 321");
    expect(sum2(1,3), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert5", () { // 1
    expect(sum(2,2), 4, reason: "Verificando o valor 123");
    expect(sum(2,2), 4, reason: "Verificando o valor 321");
    expect(sum2(2,2), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert6", () { // 2
    expect(sum(1,3), 4, reason: "Verificando o valor 123");
    expect(sum(2,2), 4, reason: "Verificando o valor 321");
    expect(sum2(2,2), 4, reason: "Verificando o valor 123");
    expect(sum2(1,3), 4, reason: "Verificando o valor 123");
  });
}

int sum(x,y) => x + y;
int sum2(x,y) => x + y;

