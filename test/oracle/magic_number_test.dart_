void main() {
  test(
    'imageParser generates ImageDetail with width: 656, height: 453',
    () {
      final actual = imageParser(testImage);

      expect(actual.width, 656);
      expect(actual.height, 453);
      expect(actual.image, isNotNull);
    },
  );

  test(
    'imageParser generates ImageDetail with width: 656, height: 453'
    'when passing inputFormat: ImageFormat.png',
    () {
      final actual = imageParser(
        testImage,
        inputFormat: ImageFormat.png,
      );

      expect(actual.width, 656);
      expect(actual.height, 453);
      expect(actual.image, isNotNull);
    },
  );

  test(
    'imageParser throws InvalidInputFormatError'
    'when passing wrong inputFormat, ImageFormat.jpeg',
    () {
      expect(
        () => imageParser(
          testImage,
          inputFormat: ImageFormat.jpeg,
        ),
        throwsA(const TypeMatcher<InvalidInputFormatError>()),
      );
    },
  );

  test('expectations', () {
    expect(Result.ok(2).expect('foo'), equals(2));
    expect(() => Result.err(Exception()).expect('oh no'), throwsException);
    expect(() => Result.ok(2).expectErr('foo'), throwsException);
    expect(Result.err(Exception()).expectErr('oh no'), isA<Exception>());
  });

  test('matching results', () {
    var called = 0;
    var returned = Result.ok(3).match(
      (v) {
        expect(v, equals(3));
        called++;
        return 1;
      },
      (err) => fail('oh no'),
    );
    expect(returned, equals(1));
    expect(called, equals(1));
    returned = Result.err(Exception()).match((v) => fail('oh no'), (err) {
      expect(err, isNotNull);
      called++;
      return 2;
    });
    expect(returned, equals(2));
    expect(called, equals(2));
  });

  test('matching options', () {
    var called = 0;
    Option.some(3).match(
      (v) {
        expect(v, equals(3));
        called++;
      },
      () => fail('oh no'),
    );
    expect(called, equals(1));
    Option.none().match((v) => fail('oh no'), () => called++);
    expect(called, equals(2));
  });

  test('when matching options', () {
    var called = 0;
    Option.some(3).when(
      some: (v) {
        expect(v, equals(3));
        called++;
      },
      none: () => fail('oh no'),
    );
    expect(called, equals(1));
    Option.none().when(
      some: (v) => fail('oh no'),
      none: () => called++,
    );
    expect(called, equals(2));
  });

  testWidgets(
    'pump Crop with minimum arguments works without errors',
    (tester) async {
      final widget = withMaterial(
        Crop(
          image: testImage,
          onCropped: (value) {},
        ),
      );

      await tester.pumpWidget(widget);
    },
  );

  testWidgets('Produces correct pixels', (WidgetTester tester) async {
    selectionController.selectedIndex = 1;
    await tester.pumpWidget(buildListButtonScaffold());
    await expectLater(
      find.byType(TypeLiteral<ListButton<String>>().type),
      matchesGoldenFile('list_button_test.golden.png'),
    );
  });


  testWidgets('ListButtonWidth.expand fails with unbounded with', (WidgetTester tester) async {
    await tester.pumpWidget(buildListButtonScaffold(width: ListButtonWidth.expand));
    expect(tester.takeException(), isFlutterError);
  });


  test('property map contains valid bool Properties', () {
    var propertyMap = Renderer_Foo.propertyMap();
    var b1 = propertyMap['b1']!;
    expect(b1.getValue, isNotNull);
    expect(b1.renderVariable, isNotNull);
    expect(b1.getBool, isNotNull);
    expect(b1.renderIterable, isNull);
    expect(b1.isNullValue, isNotNull);
    expect(b1.renderValue, isNull);
  });


  test('Renderer resolves outer variable with key with more than three names',
      () async {
    var bazTemplateFile = getFile('/project/baz.mustache')
      ..writeAsStringSync('Text {{#bar}}{{bar.foo.baz.bar.foo.s1}}{{/bar}}');
    var baz = Baz()..bar = (Bar()..foo = (Foo()..s1 = 'hello'));
    var bazTemplate = await Template.parse(bazTemplateFile);
    baz.bar!.foo!.baz = baz;
    expect(renderBaz(baz, bazTemplate), equals('Text hello'));
  });
}
