import 'package:process_run/stdio.dart';
import 'package:test/test.dart';

void main() {
  test("PrintStatmentFixture", () => {print("teste1")});
  test("PrintStatmentFixture", () => {prints("teste2")});
  test("PrintStatmentFixture", () => {stdout.write("teste3")});
  test("PrintStatmentFixture", () => {stderr.writeln("teste4")});
}
