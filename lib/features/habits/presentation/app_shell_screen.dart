import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../dashboard/presentation/dashboard_tab.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../insights/presentation/insights_providers.dart';
import '../../insights/presentation/insights_tab.dart';
import '../../wellbeing/presentation/wellbeing_summary_provider.dart';
import 'habits_list_tab.dart';
import 'habits_providers.dart';
import 'profile_tab.dart';

/// Expõe [selectTab] para filhos mudarem aba sem Riverpod (ex.: vazio checklist → Hábitos).
class PulseShellTabs extends InheritedWidget {
  const PulseShellTabs({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final ValueChanged<int> selectTab;

  static PulseShellTabs? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PulseShellTabs>();

  static PulseShellTabs of(BuildContext context) {
    final t = maybeOf(context);
    assert(t != null, 'PulseShellTabs não encontrado');
    return t!;
  }

  @override
  bool updateShouldNotify(PulseShellTabs oldWidget) =>
      selectTab != oldWidget.selectTab;
}

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  static const path = '/app';

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen>
    with WidgetsBindingObserver {
  int _index = 0;
  Timer? _midnightTimer;

  void _selectTab(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _armMidnightTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = ref.read(authRepositoryProvider).currentUserId;
      if (uid == null || uid.isEmpty) return;
      final notif = ref.read(pulseHabitNotificationSchedulerProvider);
      try {
        await ref.read(gamificationCoordinatorProvider).ensureProfile(uid);
        await notif.requestPermissionsIfNeeded();
        await notif.rescheduleAll(uid);
      } catch (_) {
        // Plataforma sem plugin completo ou permissão negada.
      }
      try {
        await ref.read(pulseSyncEngineProvider).retryFailed();
      } catch (_) {}
      await _syncAndRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // O dia pode ter virado ou outro aparelho pode ter sincronizado enquanto em segundo plano.
    _invalidateData();
    _armMidnightTimer();
    _syncAndRefresh();
  }

  /// Vira o checklist para o novo dia mesmo com o app aberto à meia-noite.
  void _armMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextDay.difference(now) + const Duration(seconds: 1),
      () {
        if (!mounted) return;
        _invalidateData();
        ref.read(backgroundRescheduleProvider)();
        _armMidnightTimer();
      },
    );
  }

  void _invalidateData() {
    ref.invalidate(todayHabitsProvider);
    ref.invalidate(dashboardSnapshotProvider);
    ref.invalidate(insightsListProvider);
    ref.invalidate(gamificationProfileProvider);
    ref.invalidate(unlockedAchievementsProvider);
    ref.invalidate(wellbeingUiSummaryProvider);
    ref.invalidate(habitMetricsProvider);
  }

  /// Push + pull; depois reflete na tela e nos lembretes o que veio do servidor.
  Future<void> _syncAndRefresh() async {
    final uid = ref.read(authRepositoryProvider).currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      await ref.read(pulseSyncEngineProvider).bootstrap(uid);
    } catch (_) {
      // Rede/supabase opcionalmente ausente — fila permanece offline.
    }
    if (!mounted) return;
    _invalidateData();
    ref.read(backgroundRescheduleProvider)();
  }

  @override
  Widget build(BuildContext context) {
    return PulseShellTabs(
      selectTab: _selectTab,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _index,
          children: const [
            DashboardTab(),
            HabitsListTab(),
            InsightsTab(),
            ProfileTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          height: 64,
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(
                Icons.space_dashboard_rounded,
                color: PulseColors.accent,
              ),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(
                Icons.list_alt_rounded,
                color: PulseColors.accent,
              ),
              label: 'Hábitos',
            ),
            NavigationDestination(
              icon: Icon(Icons.lightbulb_outline_rounded),
              selectedIcon: Icon(
                Icons.lightbulb_rounded,
                color: PulseColors.accent,
              ),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: PulseColors.accent,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
