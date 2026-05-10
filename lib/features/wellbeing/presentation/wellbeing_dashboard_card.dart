import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/theme/app_colors.dart';
import 'wellbeing_history_screen.dart';
import 'wellbeing_quick_sheet.dart';
import 'wellbeing_summary_provider.dart';

final _compactCheckInFmt = DateFormat('dd/MM/yyyy HH:mm');

/// Cartão ou faixa compacta “Humor” no dashboard.
class WellbeingDashboardCard extends ConsumerWidget {
  const WellbeingDashboardCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final bundleAsync = ref.watch(wellbeingUiSummaryProvider);

    return bundleAsync.when(
      loading: () => GlassPanel(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 16,
        ),
        child: Row(
          children: [
            SizedBox(
              width: compact ? 18 : 22,
              height: compact ? 18 : 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: PulseColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando humor…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      error: (e, _) => GlassPanel(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 16,
        ),
        child: Text(
          'Não foi possível carregar o humor: $e',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (bundle) {
        final s = bundle.summary;
        if (!s.hasAnyLog) {
          if (compact) {
            return GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.mood_outlined, color: cs.onSurfaceVariant, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Humor: ainda sem registro.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showWellbeingQuickSheet(context, ref);
                    },
                    child: const Text('Registrar'),
                  ),
                ],
              ),
            );
          }
          return GlassPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Humor',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: cs.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Registre como está se sentindo para ver tendências e melhorar os insights.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showWellbeingQuickSheet(context, ref);
                  },
                  icon: const Icon(Icons.mood_rounded),
                  label: const Text('Registrar'),
                ),
              ],
            ),
          );
        }

        final last = s.lastLog!;
        final lastDt =
            DateTime.fromMillisecondsSinceEpoch(last.loggedAtMs, isUtc: false);
        final checkInLine = _compactCheckInFmt.format(lastDt);

        if (compact) {
          return GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mood_rounded, color: PulseColors.accent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Humor',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: cs.onSurface,
                            ),
                      ),
                      if (s.moodAvgLast7CalendarDays != null)
                        Text(
                          'Média 7 d: ${_fmt1(s.moodAvgLast7CalendarDays!)} · '
                          'energia ${_fmt1(s.energyAvgLast7CalendarDays!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        'Check-in mais recente: $checkInLine',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const WellbeingHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('Histórico'),
                ),
                IconButton(
                  tooltip: 'Novo check-in',
                  icon: const Icon(Icons.add_rounded),
                  color: PulseColors.accent,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showWellbeingQuickSheet(context, ref);
                  },
                ),
              ],
            ),
          );
        }

        final dateStr =
            MaterialLocalizations.of(context).formatShortDate(lastDt);
        final timeStr = TimeOfDay.fromDateTime(lastDt).format(context);

        return GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Humor',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check-in mais recente: $dateStr · $timeStr',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (s.moodAvgLast7CalendarDays != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Média últimos 7 dias: humor ${_fmt1(s.moodAvgLast7CalendarDays!)} '
                  '· energia ${_fmt1(s.energyAvgLast7CalendarDays!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (s.correlationLine != null) ...[
                const SizedBox(height: 8),
                Text(
                  s.correlationLine!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const WellbeingHistoryScreen(),
                    ),
                  );
                },
                child: const Text('Ver histórico'),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fmt1(double x) => x.toStringAsFixed(1);
}
