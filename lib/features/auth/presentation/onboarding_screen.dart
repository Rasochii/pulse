import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../data/onboarding_storage.dart';
import '../../habits/presentation/app_shell_screen.dart';

/// Onboarding elegante — 4 passos (valor → lembretes → exemplo hábito → começar).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const path = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  Future<void> _requestNotify() async {
    final status = await Permission.notification.request();
    if (!mounted) return;
    late final String msg;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.provisional:
      case PermissionStatus.limited:
        msg = 'Lembretes ativos — você receberá avisos ao criar hábitos.';
        break;
      case PermissionStatus.denied:
        msg =
            'Permissão negada neste momento. No simulador isso pode acontecer sem o alerta da Apple '
            '(teste num iPhone físico ou ative em Ajustes › Pulse › Notificações).';
        break;
      case PermissionStatus.restricted:
        msg =
            'Notificações restritas neste dispositivo (políticas da Apple/perfil). Mais tarde você pode revisar nas Configurações.';
        break;
      case PermissionStatus.permanentlyDenied:
        msg =
            'Permissão bloqueada. Abra Ajustes › Pulse › Notificações e ative quando quiser.';
        break;
    }
    showPulseSnackBar(context, msg, kind: PulseSnackKind.neutral);
  }

  /// Opcional — requer tabela `profiles` no Supabase + RLS.
  Future<void> _syncProfilesTable() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final now = DateTime.now().toUtc().toIso8601String();
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'updated_at': now,
        'onboarding_completed_at': now,
      });
    } catch (_) {
      // Schema opcional no início do projeto.
    }
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await setOnboardingDoneForUser(userId);
    await _syncProfilesTable();
    if (!mounted) return;
    context.go(AppShellScreen.path);
  }

  Future<void> _next() async {
    if (_index >= 3) return;
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulseColors.background,
      body: Stack(
        children: [
          _GlowOrb(
            alignment: Alignment.topRight,
            tint: PulseColors.accent.withValues(alpha: .12),
          ),
          _GlowOrb(
            alignment: Alignment.bottomLeft,
            tint: PulseColors.success.withValues(alpha: .1),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed:
                            _index == 0
                                ? null
                                : () => _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 320),
                                      curve: Curves.easeOutCubic,
                                    ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: PulseColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_index + 1}/4',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(4, (i) {
                      final active = i <= _index;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            color: active
                                ? PulseColors.accent.withValues(alpha: .9)
                                : PulseColors.borderSubtle
                                    .withValues(alpha: .45),
                          ),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child: PageView(
                      physics: const BouncingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged:
                          (v) => setState(() => _index = v.clamp(0, 3)),
                      children: [
                        _IntroSlide(onContinue: _next),
                        _NotifySlide(
                          onAllow: () async {
                            await _requestNotify();
                            if (!mounted) return;
                            await _next();
                          },
                          onSkip: () {
                            showPulseSnackBar(
                              context,
                              'Você pode ativar lembretes depois nas configurações.',
                              kind: PulseSnackKind.neutral,
                            );
                            _next();
                          },
                        ),
                        _HabitPromptSlide(onContinue: _next),
                        _ReadySlide(onStart: _finish),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.alignment, required this.tint});

  final Alignment alignment;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: SizedBox(
          height: 220,
          width: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: .45),
                  blurRadius: 100,
                  spreadRadius: 56,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      icon: Icons.auto_graph_rounded,
      title: 'Evolua com consistência',
      subtitle:
          'Pulse transforma hábitos em progresso mensurável: streaks, níveis e reflexões sobre onde você cresce.',
      primaryLabel: 'Continuar',
      onPrimary: () async {
        HapticFeedback.lightImpact();
        onContinue();
      },
    );
  }
}

class _NotifySlide extends StatelessWidget {
  const _NotifySlide({
    required this.onAllow,
    required this.onSkip,
  });

  final Future<void> Function() onAllow;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      icon: Icons.notifications_active_outlined,
      title: 'Lembretes no seu ritmo',
      subtitle:
          'Combinamos lembretes com os horários que você definir, sem sobrecarga. Você controla permissões.',
      primaryLabel: 'Permitir lembretes',
      onPrimary: () async {
        HapticFeedback.lightImpact();
        await onAllow();
      },
      secondaryBelowPrimary: true,
      secondary: TextButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onSkip();
        },
        child: const Text(
          'Agora não',
          style: TextStyle(color: PulseColors.textSecondary),
        ),
      ),
    );
  }
}

class _HabitPromptSlide extends StatelessWidget {
  const _HabitPromptSlide({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _SlideShell(
      icon: Icons.task_alt_rounded,
      title: 'Seu primeiro hábito',
      subtitle:
          'Nomeie uma rotina pequena que você já consegue manter alguns dias. Exemplo: água, leitura, alongamento.',
      primaryLabel: 'Continuar',
      onPrimary: () async {
        HapticFeedback.lightImpact();
        onContinue();
      },
    );
  }
}

class _ReadySlide extends StatelessWidget {
  const _ReadySlide({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                size: 56,
                color: PulseColors.success,
              ),
              const SizedBox(height: 28),
              Text(
                'Tudo pronto',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Seu próximo nível vive nas pequenas escolhas repetidas. Vamos começar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: PulseColors.success,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Começar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PulseColors.background,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 260.ms),
      ),
    );
  }
}

class _SlideShell extends StatelessWidget {
  const _SlideShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondary,
    this.secondaryBelowPrimary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final Future<void> Function() onPrimary;
  final Widget? secondary;
  /// Se true, botão principal fica primeiro (recomendado para telas de permissão).
  final bool secondaryBelowPrimary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final bodyHeight = (h - 32).clamp(280.0, 900.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: bodyHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    child: Icon(
                      icon,
                      size: 72,
                      color: PulseColors.accent.withValues(alpha: .92),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 240.ms)
                      .scale(begin: const Offset(.97, .97)),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate(delay: 50.ms).fadeIn(duration: 240.ms),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate(delay: 90.ms).fadeIn(duration: 240.ms),
                  const Spacer(),
                  if (secondary != null && !secondaryBelowPrimary) ...[
                    secondary!,
                    const SizedBox(height: 10),
                  ],
                  FilledButton(
                    onPressed: () async {
                      await onPrimary();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: PulseColors.accent,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: PulseColors.background,
                      ),
                    ),
                  ),
                  if (secondary != null && secondaryBelowPrimary) ...[
                    const SizedBox(height: 12),
                    Center(child: secondary!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}