import 'dart:io';

import 'package:test/test.dart';

void main() {
  test("DetectorResourceOptimism", () {
    // ignore: unused_local_variable
    var file = File('file.txt');
  });

  test("DetectorResourceOptimism", () {
    // ignore: unused_local_variable
    var file = File('file.txt').exists();
  });

  test("DetectorResourceOptimism", () {
    // ignore: unused_local_variable
    var file = File('file.txt').existsSync();
  });

  test("DetectorResourceOptimism", () {
    // ignore: unused_local_variable
    if(File('file.txt').existsSync()){
      var file = File('file.txt');
    }
  });
}
