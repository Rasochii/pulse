import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/utils/date_key.dart';
import '../../../core/theme/app_colors.dart';
import '../../gamification/domain/level_curve.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../habits/presentation/habits_providers.dart';
import '../../habits/presentation/today_habit_checklist.dart';
import '../../insights/presentation/insights_providers.dart';
import '../../wellbeing/presentation/wellbeing_dashboard_card.dart';
import '../../wellbeing/presentation/wellbeing_quick_sheet.dart';
import '../../wellbeing/presentation/wellbeing_summary_provider.dart';
import '../domain/dashboard_snapshot.dart';
import 'dashboard_providers.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Color _heatColor(HeatTone t, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (t) {
      case HeatTone.muted:
        return cs.outline.withValues(alpha: dark ? 0.48 : 0.55);
      case HeatTone.missed:
        return const Color(0xFF8B3A3A);
      case HeatTone.partial:
        return const Color(0xFFD4A017);
      case HeatTone.perfect:
        return PulseColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardSnapshotProvider);
    final gmAsync = ref.watch(gamificationProfileProvider);
    final now = DateTime.now();

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pulse_dashboard_wellbeing_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          showWellbeingQuickSheet(context, ref);
        },
        icon: const Icon(Icons.mood_rounded),
        label: const Text('Humor'),
      ),
      body: RefreshIndicator(
        color: PulseColors.accent,
        onRefresh: () async {
          ref.invalidate(dashboardSnapshotProvider);
          ref.invalidate(todayHabitsProvider);
          ref.invalidate(insightsListProvider);
          ref.invalidate(gamificationProfileProvider);
          ref.invalidate(wellbeingUiSummaryProvider);
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
        child: SafeArea(
          bottom: false,
          child: dashAsync.when(
            loading: () => const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: PulseColors.accent),
                  ),
                ),
              ],
            ),
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [Text('Erro no dashboard: $e')],
            ),
            data: (dash) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList.list(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${_greeting(now)}, ${dash.displayNameGuess}!',
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(color: cs.onSurface),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Resumo do dia e da sua consistência.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          gmAsync.when(
                            loading: () => const SizedBox(
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PulseColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (gp) {
                              if (gp == null) {
                                return const SizedBox.shrink();
                              }
                              return _DashboardHeaderXp(
                                profile: gp,
                                colorScheme: cs,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Checklist de hoje',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: 8),
                      const TodayHabitChecklist(),
                      const SizedBox(height: 22),
                      if (!dash.hasHabits) ...[
                        GlassPanel(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vamos começar',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(color: cs.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Crie o primeiro hábito para ver gráficos, heatmap e sequência — '
                                'leva menos de um minuto.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _MiniStatRow(dash: dash),
                        const SizedBox(height: 14),
                        Text(
                          'Últimos 7 dias',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(color: cs.onSurface),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY:
                                  (dash.barLast7.isEmpty
                                          ? 1
                                          : dash.barLast7.reduce(
                                              (a, b) => a > b ? a : b,
                                            ))
                                      .toDouble()
                                      .clamp(1, 999) *
                                  1.15,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24,
                                    getTitlesWidget: (v, meta) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= dash.barLast7.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final dayStart = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      );
                                      final barDay = dayStart.subtract(
                                        Duration(days: 6 - i),
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          shortWeekdayPt(barDay),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (var i = 0; i < dash.barLast7.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: dash.barLast7[i].toDouble(),
                                        width: 14,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                        color: PulseColors.accent,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Heatmap (14 semanas · segunda a domingo)',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(color: cs.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: _DashboardHeatmap(
                            rows: dash.heatmap,
                            colorOf: (t) => _heatColor(t, context),
                            labelStyle: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _LegendDot(
                              color: _heatColor(HeatTone.perfect, context),
                              label: 'Meta fechada',
                            ),
                            _LegendDot(
                              color: _heatColor(HeatTone.partial, context),
                              label: 'Parcial',
                            ),
                            _LegendDot(
                              color: _heatColor(HeatTone.missed, context),
                              label: 'Atrasado',
                            ),
                            _LegendDot(
                              color: _heatColor(HeatTone.muted, context),
                              label: 'Sem meta',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (dash.topHabits14d.isNotEmpty) ...[
                          Text(
                            'Top consistência (14 d)',
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: cs.onSurface),
                          ),
                          const SizedBox(height: 8),
                          for (final t in dash.topHabits14d)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(
                                    '${t.name} · ${(t.rate * 100).round()}%',
                                  ),
                                  backgroundColor: cs.surfaceContainerHighest,
                                  side: BorderSide.none,
                                ),
                              ),
                            ),
                        ],
                        if (dash.peakHours30d.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Horários com mais registros',
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: cs.onSurface),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final h in dash.peakHours30d)
                                Chip(
                                  label: Text(
                                    '~${h.hour}h (${h.count}×)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: cs.surfaceContainerHigh
                                      .withValues(alpha: 0.75),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                      const WellbeingDashboardCard(compact: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Heatmap compacto com células fixas (12px), dias S,T,Q,… centrado na largura disponível.
class _DashboardHeatmap extends StatelessWidget {
  const _DashboardHeatmap({
    required this.rows,
    required this.colorOf,
    required this.labelStyle,
  });

  final List<List<HeatTone>> rows;
  final Color Function(HeatTone) colorOf;
  final TextStyle? labelStyle;

  static const _cell = 12.0;
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              SizedBox(
                width: _cell,
                child: Text(
                  kWeekdayLettersPt[i],
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var j = 0; j < row.length; j++) ...[
                  if (j > 0) const SizedBox(width: _gap),
                  Container(
                    width: _cell,
                    height: _cell,
                    decoration: BoxDecoration(
                      color: colorOf(row[j]),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Faixa de nível/XP logo abaixo da saudação no dashboard.
class _DashboardHeaderXp extends StatelessWidget {
  const _DashboardHeaderXp({required this.profile, required this.colorScheme});

  final GamificationProfile profile;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final into = xpIntoCurrentLevel(profile.totalXp);
    final need = xpToReachNextLevel(profile.totalXp);
    final denom = into + need;
    final p = denom <= 0
        ? 0.0
        : (into.toDouble() / denom.toDouble()).clamp(0.0, 1.0).toDouble();

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Nível ${profile.level}',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${profile.totalXp} XP',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 7,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: PulseColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faltam $need XP para o próximo nível.',
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatRow extends StatelessWidget {
  const _MiniStatRow({required this.dash});

  final DashboardSnapshot dash;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoje', style: Theme.of(context).textTheme.labelMedium),
                Text(
                  '${(dash.completionRateToday * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: PulseColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dias ideais',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  '${dash.perfectStreakDays}',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: PulseColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soma 7 d',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  '${dash.completionsSumLast7}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
