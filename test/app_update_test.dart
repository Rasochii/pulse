import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/update/app_update.dart';
import 'package:pulse/core/update/update_gate.dart';

class _FakeChecker extends AppUpdateChecker {
  _FakeChecker(this.status);

  UpdateStatus status;
  int? dismissed;

  @override
  Future<UpdateStatus> check() async => status;

  @override
  Future<void> dismissRecommended(int build) async => dismissed = build;
}

void main() {
  group('evaluateUpdate', () {
    UpdateLevel eval(int current, {int min = 0, int recommended = 0}) =>
        evaluateUpdate(
          currentBuild: current,
          minBuild: min,
          recommendedBuild: recommended,
        );

    test('sem regras: em dia', () {
      expect(eval(5), UpdateLevel.none);
    });

    test('abaixo do mínimo: obrigatória', () {
      expect(eval(5, min: 6), UpdateLevel.required);
      expect(eval(5, min: 6, recommended: 9), UpdateLevel.required);
    });

    test('no mínimo exato: liberado', () {
      expect(eval(6, min: 6), UpdateLevel.none);
    });

    test('acima do mínimo e abaixo do recomendado: só aviso', () {
      expect(eval(7, min: 6, recommended: 8), UpdateLevel.recommended);
    });

    test('build desconhecido nunca bloqueia', () {
      expect(eval(0, min: 99), UpdateLevel.none);
    });
  });

  group('UpdateGate', () {
    Future<void> pump(WidgetTester tester, _FakeChecker checker) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UpdateGate(
            checker: checker,
            child: const Scaffold(body: Text('conteúdo do app')),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('em dia: mostra o app', (tester) async {
      await pump(tester, _FakeChecker(UpdateStatus.upToDate));
      expect(find.text('conteúdo do app'), findsOneWidget);
      expect(find.text('Atualizar'), findsNothing);
    });

    testWidgets('obrigatória: troca o app pela tela de bloqueio', (tester) async {
      await pump(
        tester,
        _FakeChecker(
          const UpdateStatus(
            UpdateLevel.required,
            storeUrl: 'https://play.google.com/store/apps/details?id=x',
          ),
        ),
      );
      expect(find.text('Atualize o Pulse para continuar'), findsOneWidget);
      expect(find.text('conteúdo do app'), findsNothing);
    });

    testWidgets('recomendada: aviso por cima do app, que dá para dispensar',
        (tester) async {
      final checker = _FakeChecker(
        const UpdateStatus(
          UpdateLevel.recommended,
          storeUrl: 'https://example.com',
          recommendedBuild: 8,
        ),
      );
      await pump(tester, checker);
      expect(find.text('conteúdo do app'), findsOneWidget);
      expect(find.text('Nova versão do Pulse disponível.'), findsOneWidget);

      await tester.tap(find.text('Agora não'));
      await tester.pump();
      expect(find.text('Nova versão do Pulse disponível.'), findsNothing);
      expect(checker.dismissed, 8);
    });
  });
}
