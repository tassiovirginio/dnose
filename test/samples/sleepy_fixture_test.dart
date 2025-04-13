import 'package:test/test.dart';
import 'dart:io';

void main() async {
  var m = M();

  const umSegundo = 1;
  test("SleepyFixture", () {
    sleep(Duration(seconds: umSegundo));
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture1",
      () async {
        await Future.delayed(Duration(seconds: 1));
        expect((2+2), 4, reason: "Verificando o valor 123");
        });

  test("SleepyFixture2", () async {
    m.sleep(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture3", () async {
    m.delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });

  test("SleepyFixture4", () async{
    delayed(1);
    expect((2+2), 4, reason: "Verificando o valor 123");
    });
}

class M {
  void delayed(x) {
    print(x);
  }
  void sleep(x){
    print(x);
  }
}

void delayed(x) {
  print(x);
}

// void sleep(d){
//   print("");
// }