import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/features/habits/presentation/habit_form_screen.dart';

void main() {
  testWidgets(
    'espalhar lembretes: sugere pela meta, gera os horários e cabe em 360 px',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildPulseDarkTheme(),
            home: const HabitFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor numérico'),
        '8',
      );
      await tester.scrollUntilVisible(
        find.text('Ativar lembretes neste hábito'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Ativar lembretes neste hábito'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Meta de 8'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.textContaining('Meta de 8'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Vai lembrar nestes horários'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(Chip), findsNWidgets(8));
      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(9));

      // Voltar para "escolher horários" mostra a lista manual intacta.
      final removeIcon = find.byIcon(
        Icons.remove_circle_outline_rounded,
        skipOffstage: false,
      );
      await tester.tap(find.text('Escolher horários'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNothing);
      expect(removeIcon, findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);

      // Ida e volta não regenera nada; "ajustar um a um" leva os gerados.
      await tester.tap(find.text('Espalhar no dia'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(9));
      await tester.scrollUntilVisible(
        find.text('Ajustar estes horários um a um'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Ajustar estes horários um a um'));
      await tester.pumpAndSettle();
      expect(removeIcon, findsNWidgets(9));
    },
  );
}
