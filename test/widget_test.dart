import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse/features/auth/presentation/login_screen.dart';
import 'package:pulse/features/auth/presentation/onboarding_screen.dart';
import 'package:pulse/pulse_app.dart';

void main() {
  testWidgets('sem Supabase, entra em modo local e mostra o onboarding',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: PulseApp()));
    await tester.pump();
    await tester.pump(); // navegação pós-frame do SplashGate
    // flutter_animate agenda timers curtos — drenar até quiescente.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Evolua com consistência'), findsOneWidget);
  });
}
