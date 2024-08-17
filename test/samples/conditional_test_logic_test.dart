import 'package:test/test.dart';

void main() {
  test("Conditional Test Logic IF", () => {if (true) {}});
  // ignore: dead_code
  test("Conditional Test Logic IF", () => {if (true) {} else if (false) {}});

  test("Conditional Test Logic IF", () {
    while (true) {
      if (true) {}
    }
  });
  test("Conditional Test Logic FOR", () => {for (int i = 0; i < 10; i++) {}});
  test("Conditional Test Logic WHILE", () {
    while (true) {}
  });
  test("Conditional Test Logic WHILE", () {
    print("");
    while (1 == 1) {}
  });
}
