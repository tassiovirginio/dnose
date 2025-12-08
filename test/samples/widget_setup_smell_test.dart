import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WSS1: Repeated MaterialApp Scaffold setup', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('Test 1'),
        ),
      ),
    );
    expect(find.text('Test 1'), findsOneWidget);
  });

  testWidgets('WSS2: Repeated MaterialApp Scaffold setup', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('Test 2'),
        ),
      ),
    );
    expect(find.text('Test 2'), findsOneWidget);
  });

  testWidgets('WSS3: Repeated MaterialApp Scaffold setup', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: Text('Button'),
          ),
        ),
      ),
    );
    expect(find.text('Button'), findsOneWidget);
  });

  // Correct examples
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('Correct: Using helper method', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(Text('Correct Test')));
    expect(find.text('Correct Test'), findsOneWidget);
  });

  testWidgets('Correct: Another using helper method', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(Text('Another Correct Test')));
    expect(find.text('Another Correct Test'), findsOneWidget);
  });
}
