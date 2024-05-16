import 'package:google_generative_ai/google_generative_ai.dart' as ia;

const apiKey = "AIzaSyAeYV6fJV5KjxN8g1Zjlfw0CCeUYtloFjM";

void main() async {
  final model = ia.GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final prompt = '''
  
  Encontrei um test smells "Assertion Roulette" no código que vou te passar. Você poderia me dar uma solução de correção para esse problema?

Código: testWidgets('Spot check French', (WidgetTester tester) async {
    const Locale locale = Locale('fr');
    expect(GlobalCupertinoLocalizations.delegate.isSupported(locale), isTrue);
    final CupertinoLocalizations localizations = await GlobalCupertinoLocalizations.delegate.load(locale);
    expect(localizations, isA<CupertinoLocalizationFr>());
    expect(localizations.alertDialogLabel, 'Alerte');
    expect(localizations.datePickerHourSemanticsLabel(1), '1 heure');
    expect(localizations.datePickerHourSemanticsLabel(12), '12 heures');
    expect(localizations.pasteButtonLabel, 'Coller');
    expect(localizations.datePickerDateOrder, DatePickerDateOrder.dmy);
    expect(localizations.timerPickerSecondLabel(20), 's');
    expect(localizations.selectAllButtonLabel, 'Tout sélectionner');
    expect(localizations.timerPickerMinute(10), '10');
  });


  
  
  ''';

  final content = [ia.Content.text(prompt)];
  final response = await model.generateContent(content);

  print(response.text);
}
