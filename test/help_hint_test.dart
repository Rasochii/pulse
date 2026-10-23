import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/presentation/help_texts.dart';
import 'package:pulse/core/presentation/widgets/help_hint.dart';

void main() {
  testWidgets('o "?" abre a explicação e o Entendi fecha', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TitleWithHelp('Heatmap', help: HelpTexts.heatmap)),
      ),
    );

    expect(find.text(HelpTexts.heatmap.message), findsNothing);

    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text(HelpTexts.heatmap.message), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text(HelpTexts.heatmap.message), findsNothing);
  });

  testWidgets('título longo quebra a linha sem estourar', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TitleWithHelp(
            'Heatmap (14 semanas · segunda a domingo) com um texto bem comprido',
            help: HelpTexts.heatmap,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
  });
}
