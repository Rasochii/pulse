import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/presentation/friendly_error.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../gamification/domain/achievement_defs.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../insights/presentation/insights_providers.dart';
import '../../wellbeing/presentation/wellbeing_summary_provider.dart';
import '../data/habit_today_row.dart';
import '../domain/habit_daily_goal_display.dart';
import '../domain/pulse_habit_icons.dart';
import 'app_shell_screen.dart';
import 'habits_providers.dart';

class TodayHabitChecklist extends ConsumerWidget {
  const TodayHabitChecklist({super.key});

  static String _pct(double r) => '${(r * 100).round()}%';

  /// Hábitos com gravação em andamento.
  static final _busyHabitIds = <String>{};

  /// Toque no hábito: meta 1 alterna; meta numérica abre o painel de progresso.
  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    HabitTodayRow r,
  ) async {
    // Toque duplo rápido rodaria duas gravações em paralelo (e XP em dobro).
    if (!_busyHabitIds.add(r.habit.id)) return;
    HapticFeedback.lightImpact();
    final repo = ref.read(habitsRepositoryProvider);
    final offset = ref.read(checklistDayOffsetProvider);
    final day = checklistDayFor(offset, DateTime.now());
    try {
      if (r.hasNumericGoal) {
        final quantity = await showModalBottomSheet<double>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _ProgressSheet(row: r, isToday: offset == 0),
        );
        if (quantity == null) return;
        await repo.setProgress(habit: r.habit, day: day, quantity: quantity);
      } else {
        await repo.toggleCompletion(habit: r.habit, day: day);
      }
    } catch (e) {
      if (context.mounted) {
        showPulseSnackBar(
          context,
          friendlyError(e, 'Não foi possível registrar o hábito.'),
          kind: PulseSnackKind.error,
        );
      }
      return;
    } finally {
      _busyHabitIds.remove(r.habit.id);
    }

    ref.read(backgroundSyncProvider)();
    ref.read(backgroundRescheduleProvider)();
    if (!context.mounted) return;
    ref.invalidate(todayHabitsProvider);
    ref.invalidate(dashboardSnapshotProvider);
    ref.invalidate(insightsListProvider);
    ref.invalidate(gamificationProfileProvider);
    ref.invalidate(unlockedAchievementsProvider);
    ref.invalidate(wellbeingUiSummaryProvider);
    ref.invalidate(habitMetricsProvider(r.habit.id));

    final unlocked = ref.read(pendingAchievementUnlocksProvider);
    if (unlocked.isNotEmpty) {
      ref.read(pendingAchievementUnlocksProvider.notifier).state = const [];
      final titles = unlocked
          .map((k) => achievementByKey(k)?.title ?? k)
          .join(', ');
      showPulseSnackBar(
        context,
        unlocked.length == 1
            ? 'Conquista desbloqueada: $titles'
            : 'Conquistas desbloqueadas: $titles',
        kind: PulseSnackKind.success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRows = ref.watch(todayHabitsProvider);
    final offset = ref.watch(checklistDayOffsetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DaySelector(
          offset: offset,
          onSelected: (v) =>
              ref.read(checklistDayOffsetProvider.notifier).state = v,
        ),
        const SizedBox(height: 10),
        _rows(context, ref, asyncRows, offset),
      ],
    );
  }

  Widget _rows(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<HabitTodayRow>> asyncRows,
    int offset,
  ) {
    return asyncRows.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: PulseColors.accent),
        ),
      ),
      error: (e, _) => Text(
        friendlyError(e, 'Não foi possível carregar os hábitos de hoje.'),
      ),
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
                    offset == 0
                        ? 'Hoje você está livre'
                        : 'Nada agendado neste dia',
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
            final partial = r.hasNumericGoal && !r.done && r.quantity > 0;
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
                      onTap: () => _onTap(context, ref, r),
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
                                : partial
                                    ? PulseColors.accent
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
                          if (r.hasNumericGoal) ...[
                            Text(
                              formatDailyProgressLine(
                                r.quantity,
                                r.habit.dailyTarget,
                                r.habit.dailyTargetUnit,
                              ),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontSize: 11,
                                    color: cs.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: r.progress,
                                minHeight: 5,
                                backgroundColor: cs.surfaceContainerHighest,
                                color: r.done
                                    ? PulseColors.success
                                    : PulseColors.accent,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
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

/// Hoje e os dias anteriores em que ainda dá para corrigir um registro esquecido.
class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.offset, required this.onSelected});

  final int offset;
  final ValueChanged<int> onSelected;

  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  static String _label(int offset, DateTime now) {
    if (offset == 0) return 'Hoje';
    if (offset == 1) return 'Ontem';
    final d = checklistDayFor(offset, now);
    return '${_weekdays[d.weekday - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i <= kChecklistMaxDaysBack; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_label(i, now)),
                selected: offset == i,
                onSelected: (_) => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

/// Painel de progresso para hábitos com meta numérica; devolve a nova quantidade do dia.
class _ProgressSheet extends StatefulWidget {
  const _ProgressSheet({required this.row, required this.isToday});

  final HabitTodayRow row;
  final bool isToday;

  @override
  State<_ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<_ProgressSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: formatGoalNumber(widget.row.quantity),
  );

  Habit get _habit => widget.row.habit;

  double get _value =>
      double.tryParse(_controller.text.trim().replaceAll(',', '.')) ?? 0;

  void _set(double v) {
    final clamped = v < 0 ? 0.0 : v;
    setState(() => _controller.text = formatGoalNumber(clamped));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final target = _habit.dailyTarget;
    final unit = _habit.dailyTargetUnit?.trim();
    final done = isDailyTargetReached(_value, target) && _value > 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      // SafeArea: o painel não pode ficar atrás da barra de navegação do sistema.
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(16),
        // Rola quando o teclado deixa menos altura que o conteúdo.
        child: SingleChildScrollView(
          child: GlassPanel(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _habit.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                formatDailyGoalLine(target, unit),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Menos 1',
                    onPressed: () => _set(_value - 1),
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText:
                            widget.isToday ? 'Feito hoje' : 'Feito no dia',
                        suffixText: unit == null || unit.isEmpty ? null : unit,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: 'Mais 1',
                    onPressed: () => _set(_value + 1),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: target <= 0
                      ? 0
                      : (_value / target).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: done ? PulseColors.success : PulseColors.accent,
                ),
              ),
              const SizedBox(height: 18),
              // Wrap: três botões não cabem numa linha em telas estreitas.
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(0.0),
                    child: const Text('Zerar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(target),
                    child: const Text('Concluir meta'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_value),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
