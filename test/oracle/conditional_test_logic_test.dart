void main() {
  test('toFloat', () {
    ({'1': 1.0, '2.': 2.0, '-1.4': -1.4, 'foo': isNaN})
        .forEach((k, v) => expect(s.toFloat(k), v));
  });

  test('general properties', () {
    final ec = ZigzagEffectController(period: 1);
    expect(ec.duration, 1);
    expect(ec.started, true);
    expect(ec.completed, false);
    expect(ec.progress, 0);
    expect(ec.isRandom, false);
  });

  test('verify call is being made at first of frame for multi-frame animation',
      () {
    var timePassed = 0.0;
    const dt = 0.03;
    var timesCalled = 0;
    final sprite = _MockSprite();
    final spriteList = [sprite, sprite, sprite];
    final animationTicker =
        SpriteAnimation.spriteList(spriteList, stepTime: 1, loop: false)
            .createTicker();
    animationTicker.onFrame = (index) {
      expect(timePassed, closeTo(index * 1.0, dt));
      timesCalled++;
    };
    while (timePassed <= spriteList.length) {
      timePassed += dt;
      animationTicker.update(dt);
    }
    expect(timesCalled, spriteList.length);
  });

  test('breaks assertion when adding an invalid portion', () {
    final composition = ImageComposition();
    final image = _MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(100);

    final invalidRects = [
      const Rect.fromLTWH(-10, 10, 10, 10),
      const Rect.fromLTWH(10, -10, 10, 10),
      const Rect.fromLTWH(110, 10, 10, 10),
      const Rect.fromLTWH(0, 110, 10, 10),
      const Rect.fromLTWH(0, 0, 110, 110),
      const Rect.fromLTWH(20, 0, 90, 10),
      const Rect.fromLTWH(0, 20, 90, 90),
      const Rect.fromLTWH(0, 0, 190, 90),
      const Rect.fromLTWH(0, 0, 90, 190),
    ];

    invalidRects.forEach((rect) {
      expect(
        () => composition.add(image, Vector2.zero(), source: rect),
        failsAssert('Source rect should fit within the image'),
      );
    });
  });

  test('runs until all children fail.', () {
    final selector = Selector(
      children: [alwaysFailure, failureAfterTries],
    );

    var count = 0;
    while (count <= nTries) {
      selector.tick();

      expect(
        selector.status,
        count == nTries ? NodeStatus.failure : NodeStatus.running,
      );

      ++count;
    }

    verify(alwaysFailure.tick).called(count);
    expect(failureAfterTries.tickCount, count);
  });

  test('should cancel all the remaining delayed functions', () async {
      var callCount = 0;

      final throttled = throttle((String value) {
        ++callCount;
        return value;
      }, const Duration(milliseconds: 32), leading: false);

      var results = [
        throttled(['a']),
        throttled(['b']),
        throttled(['c'])
      ];

      await delay(30);

      throttled.cancel();

      expect(results, [null, null, null]);
      expect(callCount, 0);
    });

  test('toString', () {
    ({
      1: '1',
      1.5: '1.5',
      {1: 2}: '{1: 2}',
      null: ''
    }).forEach((k, v) => expect(s.toString(k), v));
  });

  test('toDate', () {
    ({
      '2012-02-27 13:27:00': DateTime.parse('2012-02-27 13:27:00'),
      'abc': null
    }).forEach((k, v) => expect(s.toDate(k), v));
  });

  test('should throttle a function', () async {
      var callCount = 0;
      final throttled = throttle(() {
        callCount++;
      }, 32.toDuration());

      throttled();
      throttled();
      throttled();

      var lastCount = callCount;
      expect(callCount.toBool(), isTrue);

      await delay(64);
      expect(callCount > lastCount, isTrue);
    });

  test('is the expected size of 100', () {
    expect(layer.tileData!.length, equals(10));
    layer.tileData!.forEach((row) {
      expect(row.length, equals(10));
    });
  });

  test('parsed colors', () {
      expect(layer.tintColorHex, equals('#ffaabb'));
      expect(
        layer.tintColor,
        equals(Color(int.parse('0xffffaabb'))),
      );
    });
}
