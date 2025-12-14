// Source - https://stackoverflow.com/q
// Posted by grepLines, modified by community. See post 'Timeline' for change history
// Retrieved 2025-12-12, License - CC BY-SA 3.0

 import 'package:flutter_test/flutter_test.dart';
 import 'package:testtest/main.dart';

 void main() {
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
     // Build our app and trigger a frame.
     await tester.pumpWidget(new MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
 });
 }
