import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/friendly_error.dart';
import '../../../core/database/app_database.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../domain/habit_daily_goal_display.dart';
import '../domain/pulse_habit_icons.dart';
import 'habit_form_screen.dart';
import 'habits_providers.dart';

class HabitsListTab extends ConsumerStatefulWidget {
  const HabitsListTab({super.key});

  @override
  ConsumerState<HabitsListTab> createState() => _HabitsListTabState();
}

class _HabitsListTabState extends ConsumerState<HabitsListTab> {
  /// Ordem recém-arrastada, mostrada até o banco devolver a lista atualizada.
  List<Habit>? _pendingOrder;

  Future<void> _openForm({Habit? habit}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
    );
    if (ok == true && mounted) {
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(habitsWatchProvider);
      ref.invalidate(dashboardSnapshotProvider);
    }
  }

  Future<void> _reorder(List<Habit> current, int oldIndex, int newIndex) async {
    if (newIndex == oldIndex) return;
    HapticFeedback.selectionClick();
    final next = [...current];
    next.insert(newIndex, next.removeAt(oldIndex));
    setState(() => _pendingOrder = next);
    try {
      await ref.read(habitsRepositoryProvider).reorderHabits(next);
      ref.read(backgroundSyncProvider)();
      ref.invalidate(todayHabitsProvider);
    } catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          friendlyError(e, 'Não foi possível salvar a nova ordem.'),
          kind: PulseSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _pendingOrder = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(habitsWatchProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        heroTag: 'pulse_habits_create_fab',
        elevation: 0,
        backgroundColor: PulseColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: PulseColors.accent),
          ),
          error: (e, _) => Center(child: Text(friendlyError(e, 'Não foi possível carregar os hábitos.'))),
          data: (fromDb) {
            final list = _pendingOrder ?? fromDb;
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 56,
                        color: PulseColors.borderSubtle,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum hábito criado.',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no + para registrar o primeiro — nome, dias da semana e lembrete opcional.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 92),
              buildDefaultDragHandles: false,
              header: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Todos os hábitos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (list.length > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Arraste pela alça para mudar a ordem (vale também no checklist).',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: PulseColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              itemCount: list.length,
              onReorderItem: (o, n) => _reorder(list, o, n),
              itemBuilder: (_, i) {
                final h = list[i];
                return Padding(
                  key: ValueKey(h.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  // Segurar o cartão também arrasta; toque curto abre o hábito.
                  child: ReorderableDelayedDragStartListener(
                    index: i,
                    child: GestureDetector(
                      onTap: () => _openForm(habit: h),
                      child: _HabitCard(
                        habit: h,
                        dragHandle: ReorderableDragStartListener(
                          index: i,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              color: PulseColors.borderSubtle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit, required this.dragHandle});

  final Habit habit;
  final Widget dragHandle;

  static String _pct(double r) => '${(r * 100).round()}%';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = habit;
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Color(h.colorArgb).withValues(alpha: .22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              pulseHabitIcon(h.iconKey),
              color: Color(h.colorArgb),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                if (h.category != null && h.category!.trim().isNotEmpty)
                  Text(
                    h.category!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  habitDailyGoalLabel(h),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 11,
                        color: PulseColors.textSecondary,
                      ),
                ),
                ref.watch(habitMetricsProvider(h.id)).when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (metrics) => Text(
                        'Sequência ${metrics.currentStreak} • taxa 30 d ${_pct(metrics.completionRate30d)}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 11,
                              color: PulseColors.textSecondary,
                            ),
                      ),
                    ),
              ],
            ),
          ),
          dragHandle,
        ],
      ),
    );
  }
}
