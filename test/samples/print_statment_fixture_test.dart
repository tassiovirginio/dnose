import 'package:process_run/stdio.dart';
import 'package:test/test.dart';

void main() {
  test("PrintStatmentFixture", () => {print("teste")});

  test("PrintStatmentFixture", () => {stdout.write("teste")});
}
