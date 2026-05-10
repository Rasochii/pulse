import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/habit_daily_goal_display.dart';
import '../domain/pulse_habit_icons.dart';
import 'app_shell_screen.dart';
import 'habits_providers.dart';

class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todayHabitsProvider);

    return SafeArea(
      child: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PulseColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Erro: $e', style: Theme.of(context).textTheme.bodyMedium),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return _Empty(
              onAdd: () => PulseShellTabs.of(context).selectTab(1),
            );
          }
          return RefreshIndicator.adaptive(
            color: PulseColors.accent,
            onRefresh: () async {
              ref.invalidate(todayHabitsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              itemCount: rows.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: PulseColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Marcando o dia com consistência.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                final r = rows[i - 1];
                final h = r.habit;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassPanel(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Color(h.colorArgb).withValues(alpha: .25),
                            borderRadius: BorderRadius.circular(12),
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
                                    .copyWith(color: PulseColors.textPrimary),
                              ),
                              if (h.category != null &&
                                  h.category!.trim().isNotEmpty)
                                Text(
                                  h.category!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontSize: 12),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  habitDailyGoalLabel(h),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 11,
                                        color: PulseColors.textSecondary,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Taxa 30 d: ${_fmtRate(r.completionRate30d)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: PulseColors.textSecondary,
                                      fontSize: 11,
                                    ),
                              ),
                              Text(
                                'Sequência: ${r.currentStreak} dia(s)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: PulseColors.accent
                                          .withValues(alpha: .9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Semantics(
                          label: r.done ? 'Desmarcar hábito' : 'Marcar hábito',
                          child: IconButton(
                            onPressed: () async {
                              final repo = ref.read(habitsRepositoryProvider);
                              await repo.toggleCompletion(
                                habit: h,
                                day: DateTime.now(),
                              );
                              ref.invalidate(todayHabitsProvider);
                            },
                            iconSize: 32,
                            icon: Icon(
                              r.done ? Icons.check_circle : Icons.circle_outlined,
                              color: r.done
                                  ? PulseColors.success
                                  : PulseColors.borderSubtle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  static String _fmtRate(double r) => '${(r * 100).round()}%';
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded,
                size: 56, color: PulseColors.borderSubtle),
            const SizedBox(height: 16),
            Text(
              'Nada agendado para hoje… ainda!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie hábitos na aba Hábitos e defina dias da semana.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAdd,
              child: const Text('Ir para hábitos'),
            ),
          ],
        ),
      ),
    );
  }
}
