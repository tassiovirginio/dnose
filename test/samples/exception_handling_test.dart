import 'package:test/test.dart';

void main() {
  void testFunction() {
    throw Exception("Erro");
  }

  test("Exception Handling1", () {
    //2
    try {
      throw Exception("Erro");
    } catch (e) {
      print(e);
    }
  });

  test("Exception Handling2", () {
    //1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    }
  });

  test("Exception Handling3", () {
    //1
    try {
      testFunction();
    } catch (e) {
      expect(e.toString(), Exception("Erro").toString());
    } finally {
      print("erro");
    }
  });
}
