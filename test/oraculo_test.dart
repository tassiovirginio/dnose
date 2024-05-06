import 'package:test/test.dart';
import 'dart:io';

void main() {
  // const valorSemDesconto = 150.0;

  const UM_SEGUNDO = 1;

  // setUpAll(() {
  // });

  // tearDownAll(() => print("Finalizando TODOS os testes..."));

  // setUp(() => print("Iniciando o teste"));

  // tearDown(() => print("Finalizando o teste"));

  // test('calculate', () {
  //   expect(calculate(), 42);
  // });

  // test('Deve clacular desconto corretamente utilizando valores decimais', () {
  //   const desconto = 25.0;
  //   const valorComDesconto = valorSemDesconto - desconto;
  //   expect(calcularDesconto(valorSemDesconto, desconto, false),
  //       equals(valorComDesconto));
  // });

  // test('Deve dar erro ao calcula valor com desconto negativo ou zero', () {
  //   expect(() => calcularDesconto(valorSemDesconto, -1, true),
  //       throwsA(TypeMatcher<ArgumentError>()));

  //   expect(() => calcularDesconto(valorSemDesconto, 0, false),
  //       throwsA(TypeMatcher<ArgumentError>()));
  // });

  // //AssertionRouletteFixture
  // test('Exemplo de DuplicateAssertFixture em DART', () {
  //   expect(() => calcularDesconto(valorSemDesconto, -1, true),
  //       throwsA(TypeMatcher<ArgumentError>()));
  //   expect(() => calcularDesconto(valorSemDesconto, -1, true),
  //       throwsA(TypeMatcher<ArgumentError>()));
  // });

  // test('Exemplo de AssertionRouletteFixture em DART', () {
  //   expect(() => calcularDesconto(valorSemDesconto, -1, true),
  //       throwsA(TypeMatcher<ArgumentError>()));

  //   expect(() => calcularDesconto(valorSemDesconto, 0, false),
  //       throwsA(TypeMatcher<ArgumentError>()));
  // });

  //teste Empty Description Test
  test("", () => {});

  //teste vazio - Empty Test
  test("EmptyFixture", () => {});

  test("ConditionalFixture IF", () => {if (true) {}});
  test("ConditionalFixture IF", () =>
  {if (true) {} else
    if(false){}});

  test("ConditionalFixture IF", () {
    while (true) {
      if (true) {}
    }
  });
  test("ConditionalFixture FOR", () => {for (int i = 0; i < 10; i++) {}});
  test("ConditionalFixture WHILE", () {
    while (true) {}
  });
  test("ConditionalFixture WHILE", () {
    print("");
    while (1 == 1) {}
  });

  test("MagicNumberFixture", () => {expect(1 + 2, 3)});

  test("DuplicateAssert", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "Verificando o valor");
  });


  test("AssertionRoulet", () {
    expect(1 + 2, 3, reason: "Verificando o valor");
    expect(1 + 2, 3, reason: "");
    expect(1 + 2, 3);
  });

  test("DetectorResourceOptimism", () {
    var file = File('file.txt');
  });

  test("PrintStatmentFixture", () => {print("")});

  test("SleepyFixture", () => {sleep(Duration(seconds: UM_SEGUNDO))});

  // test(
  //     "VerboseFixture",
  //     () => {
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3),
  //           expect(1 + 2, 3)
  //         });
}
