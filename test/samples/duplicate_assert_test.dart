import 'package:test/test.dart';

void main() {
  test("Duplicate Assert", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 3, reason: "Verificando o valor");
  });


  test("Duplicate Assert", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor");
    expect(sum(1,2), 4, reason: "Verificando o valor");
    expect(sum(1,2), 5, reason: "Verificando o valor");
  });


  test("Duplicate Assert", () { // 2
    expect(sum(1,2), 3, reason: "Verificando o valor 123");
    expect(sum(1,2), 3, reason: "Verificando o valor 321");
    expect(sum(1,2), 3, reason: "Verificando o valor 111");
  });

  test("Duplicate Assert", () { // 1
    expect(sum(1,2), 4, reason: "Verificando o valor 123");
    expect(sum(1,2), 4, reason: "Verificando o valor 321");
    expect(sum2(1,2), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert", () { // 1
    expect(sum(1,2), 4, reason: "Verificando o valor 123");
    expect(sum(1,2), 4, reason: "Verificando o valor 321");
    expect(sum2(1,2), 4, reason: "Verificando o valor 123");
  });

  test("Duplicate Assert", () { // 2
    expect(sum(1,2), 4, reason: "Verificando o valor 123");
    expect(sum(1,2), 4, reason: "Verificando o valor 321");
    expect(sum2(1,2), 4, reason: "Verificando o valor 123");
    expect(sum2(1,2), 4, reason: "Verificando o valor 123");
  });
}

int sum(x,y) => x + y;
int sum2(x,y) => x + y;

