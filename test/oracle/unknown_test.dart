void main() {
  test('Creates successfully', () {
    when(tickerProviderMock.createTicker(any)).thenReturn(Ticker((_) {}));
    BottomExpandableAppBar();
    BottomBarController(vsync: tickerProviderMock);
  });

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

  test(
    'Creating a 4 days timeline with iterval 1D and label spred 2D '
    '--> the two child item should have a duration of 2 days',
    () {
      final dates = <DateTime>[];
      final startDate = DateTime(2023, 1, 1);
      final timelines = DynamicTimeline(
        firstDateTime: startDate,
        lastDateTime: DateTime(2023, 1, 5),
        labelBuilder: LabelBuilder(
          intervalExtend: 2,
          builder: (labelDate) {
            dates.add(labelDate);
            return const Text('date');
          },
        ),
        items: const [],
        intervalDuration: const Duration(days: 1),
      );

      const twoDays = Duration(days: 2);
      final item1 = timelines.children[0] as TimelineItem;
      final item2 = timelines.children[1] as TimelineItem;

      final item1Duration = item1.endDateTime.difference(item1.startDateTime);
      final item2Duration = item2.endDateTime.difference(item2.startDateTime);

      item1Duration.should.be(twoDays);
      item2Duration.should.be(twoDays);
    },
  );

  test(
      'Test creation by factory fromString '
      '--> builder builds a text widget', () async {
    final builder = LabelBuilder.fromString((date) => date.toString());
    final now = DateTime.now();
    builder.builder(now).should.beOfType<Text>();
  });

  testWidgets('WidgetSurveyor returns correct constrained measurements', (WidgetTester tester) async {
    const WidgetSurveyor surveyor = WidgetSurveyor();
    final Size size = surveyor.measureWidget(
      SizedBox(width: 100, height: 200),
      constraints: BoxConstraints(maxWidth: 80, maxHeight: 180),
    );
    expect(size, const Size(80, 180));
  });

  test(
      'Test creation by factory fromString '
      '--> the string builder gets called', () async {
    var calls = 0;
    final builder = LabelBuilder.fromString((date) {
      calls++;
      return date.toString();
    });
    builder.builder(DateTime.now());
    calls.should.be(1);
  });

test('getEventsCount - known user', () async {
      final Map<String, int> result = await EventsAPIClient.getEventsCount(
        userId: knownUserId,
        uriHelper: uriHelper,
      );
      checkEventsCount(result, false);
    });
  test('getEventsCount - all', () async {
    final Map<String, int> result = await EventsAPIClient.getEventsCount(
      uriHelper: uriHelper,
    );
    checkEventsCount(result, false);
  });

  test('catching exceptions', () {
    final result = Result.of(() => throw Exception());
    expect(result, isA<Err>());
  });

  test('getEventsCount - known user', () async {
    final Map<String, int> result = await EventsAPIClient.getEventsCount(
      userId: knownUserId,
      uriHelper: uriHelper,
    );
    checkEventsCount(result, false);
  });
}
