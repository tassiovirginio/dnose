import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';
 

void main() {
  testWidgets('RST1: TextEditingController without dispose', (WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextField(controller: controller),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'Test');
    expect(controller.text, 'Test');
    // Missing controller.dispose()
  });

  testWidgets('RST2: StreamController without dispose', (WidgetTester tester) async {
    final controller = StreamController<String>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StreamBuilder<String>(
          stream: controller.stream,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
      ),
    ));

    controller.add('Data');
    await tester.pump();
    expect(find.text('Data'), findsOneWidget);
    // Missing controller.close()
  });

  testWidgets('RST3: AnimationController without dispose', (WidgetTester tester) async {
    final controller = AnimationController(vsync: tester);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FadeTransition(
          opacity: controller,
          child: Text('Animated'),
        ),
      ),
    ));

    controller.forward();
    await tester.pumpAndSettle();
    expect(find.text('Animated'), findsOneWidget);
    // Missing controller.dispose()
  });

  testWidgets('RST4: FocusNode without dispose', (WidgetTester tester) async {
    final focusNode = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextField(focusNode: focusNode),
      ),
    ));

    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, true);
    // Missing focusNode.dispose()
  });

  testWidgets('RST5: TabController without dispose', (WidgetTester tester) async {
    final controller = TabController(length: 2, vsync: tester);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: controller,
            tabs: [Tab(text: 'Tab1'), Tab(text: 'Tab2')],
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: [Text('Content1'), Text('Content2')],
        ),
      ),
    ));

    expect(find.text('Content1'), findsOneWidget);
    // Missing controller.dispose()
  });

  // Correct examples
  testWidgets('Correct: TextEditingController with dispose', (WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextField(controller: controller),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'Test');
    expect(controller.text, 'Test');
    controller.dispose();
  });

  testWidgets('Correct: StreamController with close', (WidgetTester tester) async {
    final controller = StreamController<String>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StreamBuilder<String>(
          stream: controller.stream,
          builder: (context, snapshot) => Text(snapshot.data ?? ''),
        ),
      ),
    ));

    controller.add('Data');
    await tester.pump();
    expect(find.text('Data'), findsOneWidget);
    controller.close();
  });
}
