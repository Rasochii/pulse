import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse/features/auth/presentation/login_screen.dart';
import 'package:pulse/pulse_app.dart';

void main() {
  testWidgets('sem Supabase, mostra login após splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PulseApp()));
    await tester.pump();
    await tester.pump(); // navegação pós-frame do SplashGate
    // flutter_animate no login agenda timers curtos — drenar até quiescente.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Bem-vindo'), findsOneWidget);
  });
}
