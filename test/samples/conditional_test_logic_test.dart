import 'package:test/test.dart';

void main() {
  test("Conditional Test Logic IF1", () => {if (true) {}});//1
  // ignore: dead_code
  test("Conditional Test Logic IF2", () => {if (true) {} else if (false) {}});//2

  test("Conditional Test Logic IF3", () {//2
    while (true) {
      if (true) {}
    }
  }, skip: true);

  test("Conditional Test Logic FOR", () => {for (int i = 0; i < 10; i++) {}});//1

  test("Conditional Test Logic WHILE1", () {//1
    while (true) {}
  }, skip: true);

  test("Conditional Test Logic WHILE2", () {//1
    print("");
    while (1 == 1) {}
  },skip: true);


  test("Conditional Test Logic Switch", () {//1
    switch (1) {
      case 1:
        break;
      default:
    }
  },skip: true);

  test("Conditional Test Logic forEach", () {//1
    List<int> list = [1,2,3];
    for (var number in list) {
      print(number);
    }
  });

}
