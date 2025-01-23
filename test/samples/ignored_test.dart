import 'package:test/test.dart';

void main() {
  test("Some Test1", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:        true);

  test("Some Test2", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "Message Ignore");


  test("Some Test3", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "");

  test("Some Test4", () async {
    //1
    //Test Logic
    expect(1 + 2, 3);
  }, skip:         "     ");

  test("Some Other Test1", () async {
    //0
    //Test Logic
    expect(1 + 2, 3);
  }, skip:     false);

  test("Some Other Test2", () async {
    //0
    //Test Logic
    expect(1 + 2, 3);
  });
}
