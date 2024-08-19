import 'package:test/test.dart';

void main() {
  //Empty Description Test
  test("", () => {});
  test(" ", () {print("teste");});
  test("  ", () => {if (true) {}});
}
