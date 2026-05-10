import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../domain/habit_daily_goal_display.dart';
import '../domain/pulse_habit_icons.dart';
import 'habit_form_screen.dart';
import 'habits_providers.dart';

class HabitsListTab extends ConsumerWidget {
  const HabitsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitsWatchProvider);

    Future<void> openForm({Habit? habit}) async {
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
      );
      if (ok == true && context.mounted) {
        ref.invalidate(todayHabitsProvider);
        ref.invalidate(habitsWatchProvider);
        ref.invalidate(dashboardSnapshotProvider);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        heroTag: 'pulse_habits_create_fab',
        elevation: 0,
        backgroundColor: PulseColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: PulseColors.accent),
          ),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (list) {
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

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 92),
              itemCount: list.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Todos os hábitos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }
                final h = list[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => openForm(habit: h),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                if (h.category != null &&
                                    h.category!.trim().isNotEmpty)
                                  Text(
                                    h.category!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                Text(
                                  habitDailyGoalLabel(h),
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        fontSize: 11,
                                        color: PulseColors.textSecondary,
                                      ),
                                ),
                                Consumer(
                                  builder: (ctx, cref, _) {
                                    final m = cref.watch(
                                      habitMetricsProvider(h.id),
                                    );
                                    return m.when(
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, _) => const SizedBox.shrink(),
                                      data: (metrics) => Text(
                                        'Sequência ${metrics.currentStreak} • taxa 30 d ${_pct(metrics.completionRate30d)}',
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 11,
                                              color: PulseColors.textSecondary,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: PulseColors.borderSubtle,
                          ),
                        ],
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

  static String _pct(double r) => '${(r * 100).round()}%';
}
