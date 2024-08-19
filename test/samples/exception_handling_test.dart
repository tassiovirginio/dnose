import 'package:test/test.dart';

void main() {

  void testFunction() {
    throw Exception("Erro");
  }


  test("Exception Handling", () {
    try {
      throw Exception("Erro");
    } catch (e) {
      print(e);
    }
  });

  test("Exception Handling", () {
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    }
  });


}
