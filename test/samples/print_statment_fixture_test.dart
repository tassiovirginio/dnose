import 'package:process_run/stdio.dart';
import 'package:test/test.dart';

void main() {
  var m = M();
  var mm = M();
  test("PrintStatmentFixture", () => {m.print("teste1")});
  test("PrintStatmentFixture", () => {mm.prints("teste1")});
  test("PrintStatmentFixture", () => {print("teste1")});
  test("PrintStatmentFixture", () => {prints("teste2")});
  test("PrintStatmentFixture", () => {stdout.write("teste3")});
  test("PrintStatmentFixture", () => {stderr.writeln("teste4")});
}


class M{
  void print(a){
    print(a);
  }
  void prints(a){
    print(a);
  }
}