import 'package:web/helpers.dart';
import 'package:teste01/DNose.dart';

void main() {
  final now = DateTime.now();
  final element = document.querySelector('#output') as HTMLDivElement;
  element.text = 'The time is ${now.hour}:${now.minute}'
      ' and your Dart web app is running!';

  // final element2 = document.querySelector('#msg') as HTMLDivElement;
  // element2.text = src;
}
