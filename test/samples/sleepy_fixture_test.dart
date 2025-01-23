import 'package:test/test.dart';
import 'dart:io';

void main() async {
  var m = M();

  const umSegundo = 1;
  test("SleepyFixture", () => {sleep(Duration(seconds: umSegundo))});

  test("SleepyFixture",
      () async => {await Future.delayed(Duration(seconds: 1))});

  test("SleepyFixture2", () async => {m.sleep(1)});

  test("SleepyFixture2", () async => {m.delayed(1)});

  test("SleepyFixture2", () async => {delayed(1)});
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