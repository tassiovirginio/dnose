import 'package:process_run/stdio.dart';
import 'package:test/test.dart';

void main() {
  var m = M();
  var mm = M();
  test("PrintStatmentFixture1", () => {m.print("teste1")});
  test("PrintStatmentFixture2", () => {mm.prints("teste1")});
  test("PrintStatmentFixture3", () => {print("teste1")});
  test("PrintStatmentFixture4", () => {prints("teste2")});
  test("PrintStatmentFixture5", () => {stdout.write("teste3")});
  test("PrintStatmentFixture6", () => {stderr.writeln("teste4")});
}


class M{
  void print(a){
    print(a);
  }
  void prints(a){
    print(a);
  }
}