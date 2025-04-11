void main() {
  test('no test at present', () {});

  testWidgets('Empty AlignedGridView', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          dragStartBehavior: DragStartBehavior.down,
          crossAxisCount: 4,
          itemBuilder: (contex, index) => const SizedBox(),
          itemCount: 0,
        ),
      ),
    );
  });

  test('flame_spine', () {});

  test('Matrix.deltaTransformPoint', () {
    // ToDo
  });

  test('Mock', () {});

  testWidgets('WidgetSurveyor returns correct constrained measurements', (WidgetTester tester) async {
    const WidgetSurveyor surveyor = WidgetSurveyor();
    final Size size = surveyor.measureWidget(
      SizedBox(width: 100, height: 200),
      constraints: BoxConstraints(maxWidth: 80, maxHeight: 180),
    );
    expect(size, const Size(80, 180));
  });

  test('adds one to input values', () {});


  test('reverse speed-1', () {
      final ec = EffectController(speed: 1, alternate: true);
      expect(ec, isA<SequenceEffectController>());
      final seq = (ec as SequenceEffectController).children;
      expect(seq.length, 2);
      expect(seq[0], isA<SpeedEffectController>());
      expect(seq[1], isA<SpeedEffectController>());
      expect(
        (seq[0] as SpeedEffectController).child,
        isA<LinearEffectController>(),
      );
      expect(
        (seq[1] as SpeedEffectController).child,
        isA<ReverseLinearEffectController>(),
      );
    });

  test('sn_progress_dialog', () {});

  test('reverse speed-2', () {
      final ec = EffectController(speed: 1, reverseSpeed: 2);
      expect(ec, isA<SequenceEffectController>());
      final seq = (ec as SequenceEffectController).children;
      expect(seq.length, 2);
      expect(seq[0], isA<SpeedEffectController>());
      expect(seq[1], isA<SpeedEffectController>());
      expect((seq[0] as SpeedEffectController).speed, 1);
      expect((seq[1] as SpeedEffectController).speed, 2);
    });
}
