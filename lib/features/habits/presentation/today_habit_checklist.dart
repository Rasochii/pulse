import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../insights/presentation/insights_providers.dart';
import '../domain/pulse_habit_icons.dart';
import 'app_shell_screen.dart';
import 'habits_providers.dart';

class TodayHabitChecklist extends ConsumerWidget {
  const TodayHabitChecklist({super.key});

  static String _pct(double r) => '${(r * 100).round()}%';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRows = ref.watch(todayHabitsProvider);

    return asyncRows.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: PulseColors.accent),
        ),
      ),
      error: (e, _) => Text('Erro ao carregar hoje: $e'),
      data: (rows) {
        if (rows.isEmpty) {
          final cs = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: GlassPanel(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoje você está livre',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nenhum hábito agendado para este dia da semana. '
                    'Crie hábitos na aba Hábitos ou ajuste os dias da semana.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      PulseShellTabs.maybeOf(context)?.selectTab(1);
                    },
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Gerenciar hábitos'),
                  ),
                ],
              ),
            ),
          );
        }

        final cs = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await ref
                            .read(habitsRepositoryProvider)
                            .toggleCompletion(
                              habit: r.habit,
                              day: DateTime.now(),
                            );
                        if (!context.mounted) return;
                        ref.invalidate(todayHabitsProvider);
                        ref.invalidate(dashboardSnapshotProvider);
                        ref.invalidate(insightsListProvider);
                        ref.invalidate(gamificationProfileProvider);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: r.done
                              ? PulseColors.success.withValues(alpha: 0.35)
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: r.done
                                ? PulseColors.success
                                : cs.outline.withValues(alpha: 0.65),
                          ),
                        ),
                        child: Icon(
                          r.done ? Icons.check_rounded : Icons.add_rounded,
                          color: r.done ? Colors.white : PulseColors.accent,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                pulseHabitIcon(r.habit.iconKey),
                                size: 18,
                                color: Color(r.habit.colorArgb),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.habit.name,
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(
                                        color: cs.onSurface,
                                        decoration: r.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Série ${r.currentStreak} · taxa 30 d ${_pct(r.completionRate30d)}',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  fontSize: 11,
                                  color: PulseColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
