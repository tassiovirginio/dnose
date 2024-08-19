import 'package:test/test.dart';

void main() {
  //UnknownTest
  test("UnknownTest", () {
    print("teste");
  });

  test("UnknownTest", () {
    print("teste");
    if(true){
      print("teste");
    }
  });

  test("UnknownTest", () {
    print("teste");
    if(true){
      print("teste");
    }
    expect(1, 1, reason: "teste");
  });
}
