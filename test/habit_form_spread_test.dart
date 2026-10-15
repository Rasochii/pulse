import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/features/habits/presentation/habit_form_screen.dart';

void main() {
  testWidgets(
    'espalhar pelo dia: só muda a lista ao aplicar e cabe em 360 px',
    (tester) async {
      // Tela alta: a lista de horários é preguiçosa e os itens precisam existir.
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
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Ativar lembretes neste hábito'),
        200,
        scrollable: scrollable,
      );
      await tester.tap(find.text('Ativar lembretes neste hábito'));
      await tester.pumpAndSettle();
      final removeIcon = find.byIcon(Icons.remove_circle_outline_rounded);
      expect(find.text('Seu horário'), findsOneWidget);
      expect(removeIcon, findsOneWidget);

      // A sugestão pela meta abre a folha já com 8.
      await tester.tap(find.textContaining('Meta de 8'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(8));
      await tester.tap(find.byTooltip('Mais'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(9));

      // Cancelar não mexe na lista.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNothing);
      expect(removeIcon, findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);

      // Aplicar troca a lista pelos horários da prévia.
      await tester.tap(find.text('Espalhar pelo dia'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(8));
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();
      expect(find.text('Seus 8 horários'), findsOneWidget);
      expect(removeIcon, findsNWidgets(8));
    },
  );
}
