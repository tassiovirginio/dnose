import 'package:process_run/stdio.dart';
import 'package:test/test.dart';

void main() {
  
  test("PrintStatmentFixture1", () {
    var m = M();
    m.print("teste1");
    expect((2+2), 4, reason: "Verificando o valor 123");
    });
  test("PrintStatmentFixture2", () {
    var mm = M();
    mm.prints("teste1");
    });
  test("PrintStatmentFixture3", () => {print("teste1")});
  test("PrintStatmentFixture4", () => {prints("teste2")});
  test("PrintStatmentFixture5", () => {stdout.write("teste3")});
  test("PrintStatmentFixture6", () => {stderr.writeln("teste4")});
}


class M{
  void print(a){
    stdout.write('$a\n');
  }
  void prints(a){
    stdout.write('$a\n');
  }
}