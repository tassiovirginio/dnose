import 'package:test/test.dart';

void main() {
  test("Conditional Test Logic IF", () => {if (true) {}});
  // ignore: dead_code
  test("Conditional Test Logic IF", () => {if (true) {} else if (false) {}});

  test("Conditional Test Logic IF", () {
    while (true) {
      if (true) {}
    }
  }, skip: true);

  test("Conditional Test Logic FOR", () => {for (int i = 0; i < 10; i++) {}});

  test("Conditional Test Logic WHILE", () {
    while (true) {}
  }, skip: true);

  test("Conditional Test Logic WHILE", () {
    print("");
    while (1 == 1) {}
  },skip: true);


  test("Conditional Test Logic Switch", () {
    switch (1) {
      case 1:
        break;
      default:
    }
  },skip: true);

  test("Conditional Test Logic forEach", () {
    List<int> list = [1,2,3];
    list.forEach((number)=> print(number));
  });

}
