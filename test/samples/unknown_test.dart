import 'package:test/test.dart';

void main() {
  //UnknownTest
  test("UnknownTest1", () {
    print("teste");
  });

  test("UnknownTest2", () {
    print("teste");
    if(true){
      print("teste");
    }
  });

  test("UnknownTest3", () {
    print("teste");
    if(true){
      print("teste");
    }
    expect(1, 1, reason: "teste");
  });


  test("UnknownTest4", () {
    print("teste");
    if(true){
      print("teste");
    }
    // expect(1, 1, reason: "teste");
  });
}
