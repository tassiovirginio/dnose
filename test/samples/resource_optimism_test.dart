import 'dart:io';

import 'package:test/test.dart';

void main() {
  test("DetectorResourceOptimism1", () {
    // ignore: unused_local_variable
    var file = File('file.txt');
  });

  test("DetectorResourceOptimism2", () {
    // ignore: unused_local_variable
    var file = File('file.txt').exists();
  });

  test("DetectorResourceOptimism3", () {
    // ignore: unused_local_variable
    var file = File('file.txt').existsSync();
  });

  test("DetectorResourceOptimism4", () {
    if(File('file.txt').existsSync()){
      // ignore: unused_local_variable
      var file = File('file.txt');
    }
  });
}
