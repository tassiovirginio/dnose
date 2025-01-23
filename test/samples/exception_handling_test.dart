import 'package:test/test.dart';

void main() {

  void testFunction() {
    throw Exception("Erro");
  }


  test("Exception Handling", () {//2
    try {
      throw Exception("Erro");
    } catch (e) {
      print(e);
    }
  });

  test("Exception Handling", () {//1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    }
  });

  test("Exception Handling", () {//1
    try {
      testFunction();
    } finally {
      print("erro");
    }
  });


}
