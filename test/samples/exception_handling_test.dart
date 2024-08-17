import 'package:test/test.dart';

void main() {
  test("Exception Handling", () {
    try {
      throw Exception("Erro");
    } catch (e) {
      print(e);
    }
  });
}
