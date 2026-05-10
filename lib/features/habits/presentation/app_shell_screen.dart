import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../dashboard/presentation/dashboard_tab.dart';
import '../../insights/presentation/insights_tab.dart';
import 'habits_list_tab.dart';
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

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  int _index = 0;

  void _selectTab(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = ref.read(authRepositoryProvider).currentUser?.id;
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
        await ref.read(pulseSyncEngineProvider).bootstrap(uid);
      } catch (_) {
        // Rede/supabase opcionalmente ausente — fila permanece offline.
      }
    });
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
