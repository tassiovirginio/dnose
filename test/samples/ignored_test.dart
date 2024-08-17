import 'package:test/test.dart';

void main() {
  test("Some Test", () async {
    //Test Logic
    expect(1 + 2, 3);
  }, skip: true);

  test("Some Other Test", () async {
    //Test Logic
    expect(1 + 2, 3);
  }, skip: false);
}
