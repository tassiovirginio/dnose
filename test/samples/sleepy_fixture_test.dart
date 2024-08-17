import 'package:test/test.dart';
import 'dart:io';

void main() async {
  const umSegundo = 1;
  test("SleepyFixture", () => {sleep(Duration(seconds: umSegundo))});

  test("SleepyFixture",
      () async => {await Future.delayed(Duration(seconds: 1))});
}
