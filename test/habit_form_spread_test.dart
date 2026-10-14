import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/features/habits/presentation/habit_form_screen.dart';

void main() {
  testWidgets(
    'espalhar lembretes: sugere pela meta, gera os horários e cabe em 360 px',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 780 * 3);
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
    },
  );
}
