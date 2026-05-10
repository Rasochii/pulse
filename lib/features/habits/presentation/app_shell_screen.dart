import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'habits_list_tab.dart';
import 'profile_tab.dart';
import 'today_tab.dart';

/// Expõe [selectTab] para filhos mudarem aba sem Riverpod (ex.: vazio «Hoje» → Hábitos).
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

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  static const path = '/app';

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _index = 0;

  void _selectTab(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return PulseShellTabs(
      selectTab: _selectTab,
      child: Scaffold(
        backgroundColor: PulseColors.background,
        body: IndexedStack(
          index: _index,
          children: const [
            TodayTab(),
            HabitsListTab(),
            ProfileTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          height: 64,
          backgroundColor: PulseColors.surface,
          indicatorColor: PulseColors.accent.withValues(alpha: 0.2),
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today_rounded, color: PulseColors.accent),
              label: 'Hoje',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon:
                  Icon(Icons.list_alt_rounded, color: PulseColors.accent),
              label: 'Hábitos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: PulseColors.accent),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
