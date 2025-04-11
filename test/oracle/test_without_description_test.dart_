void main() {
  test('', () {
    expect(isType<String>()('string'), true);
    expect(isType<int>()(1), true);
    expect(isType<List>()([]), true);
    expect(isType<List>()(1), false);
    expect(isType<String>()({}), false);
  });

  test('', () {
    expect(isNotType<String>()(1), true);
    expect(isNotType<int>()('string'), true);
    expect(isNotType<List>()({}), true);
    expect(isNotType<List>()([]), false);
    expect(isNotType<String>()('string'), false);
  });

  test("completed doesn't complete after the animation is reset", () {
    final sprite = _MockSprite();
    final animationTicker = SpriteAnimation.spriteList(
      [sprite],
      stepTime: 1,
      loop: false,
    ).createTicker();

    animationTicker.completed;
    animationTicker.update(1);
    expect(animationTicker.completeCompleter!.isCompleted, true);

    animationTicker.reset();
    animationTicker.completed;
    expect(animationTicker.completeCompleter!.isCompleted, false);
  });

  test('', () {
    final element = InputElement()
      ..name = 'test'
      ..value = 'test value';
    final baseEvent = createSyntheticEvent(
      bubbles: true,
      cancelable: false,
      currentTarget: element,
      defaultPrevented: true,
      preventDefault: null,
      stopPropagation: null,
      eventPhase: 0,
      isTrusted: true,
      nativeEvent: 'string',
      target: element,
      timeStamp: 100,
      type: 'non-default',
    );
    testSyntheticEventBaseForMergeTests(baseEvent);

    final newElement = DivElement();
    final newEvent = createSyntheticEvent(
      baseEvent: baseEvent,
      bubbles: false,
      cancelable: true,
      currentTarget: newElement,
      defaultPrevented: false,
      preventDefault: () => mergeTestCounter++,
      stopPropagation: () => mergeTestCounter++,
      eventPhase: 2,
      isTrusted: false,
      nativeEvent: 'updated string',
      target: newElement,
      timeStamp: 200,
      type: 'updated non-default',
    );

    testSyntheticEventBaseAfterMerge(newEvent);
  });

  test('paused pauses ticket', () {
    final sprite = _MockSprite();
    final animationTicker = SpriteAnimation.spriteList(
      [sprite, sprite],
      stepTime: 1,
      loop: false,
    ).createTicker();

    expect(animationTicker.isPaused, false);
    expect(animationTicker.currentIndex, 0);
    animationTicker.update(1);
    expect(animationTicker.currentIndex, 1);
    animationTicker.paused = true;
    expect(animationTicker.isPaused, true);
    animationTicker.update(1);
    expect(animationTicker.currentIndex, 1);
    animationTicker.reset();
    expect(animationTicker.currentIndex, 0);
    expect(animationTicker.isPaused, false);
  });

  test('', () {
    const text = 'a';
    final builder = TransientTextElementsBuilder(
      oldElements: elements,
      oldText: initialText,
      newText: text,
    );
    final result = builder.build(
      changeRange: builder.findUpdatedElementsRange(),
    );
    expect(result.elements, hasLength(1));
    expect(result.elements[0].text, 'a');
    expect(result.elements[0].matcherType, TextMatcher);
    expect(result.elements[0].offset, 0);

    final spans = buildTransientSpan(
      initialElements: elements,
      elementsBuilderResult: result,
    );
    expect(spans, hasLength(1));
    expect(spans.text, text);
  });

  test('completed completes', () {
    final sprite = _MockSprite();
    final animationTicker = SpriteAnimation.spriteList(
      [sprite],
      stepTime: 1,
      loop: false,
    ).createTicker();

    expectLater(animationTicker.completed, completes);

    animationTicker.update(1);
  });

  test('', () {
    result = checkProject('${d.sandbox}/missing');

    expect(result.exitCode, equals(1));
    expect(result.stderr,
        contains('These packages are used in lib/ but are not dependencies:'));
    expect(result.stderr, contains('yaml'));
    expect(result.stderr, contains('somescsspackage'));
  });

  test('catching ok values async', () async {
    final result = await Result.asyncOf(() async => 2);
    expect(result, isA<Ok>());
    expect(result.unwrap(), equals(2));
  });

  test('expectations', () {
    expect(Result.ok(2).expect('foo'), equals(2));
    expect(() => Result.err(Exception()).expect('oh no'), throwsException);
    expect(() => Result.ok(2).expectErr('foo'), throwsException);
    expect(Result.err(Exception()).expectErr('oh no'), isA<Exception>());
  });
}
