import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import 'wellbeing_quick_sheet.dart';
import 'wellbeing_summary_provider.dart';

final _historyDateFmt = DateFormat('dd/MM/yyyy');

/// Lista dos últimos check-ins de humor (dados vindos do [wellbeingUiSummaryProvider]).
class WellbeingHistoryScreen extends ConsumerWidget {
  const WellbeingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleAsync = ref.watch(wellbeingUiSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de humor'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pulse_wellbeing_history_fab',
        onPressed: () => showWellbeingQuickSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar'),
      ),
      body: bundleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PulseColors.accent),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erro ao carregar: $e'),
          ),
        ),
        data: (bundle) {
          final logs = bundle.logsNewestFirst;
          if (logs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mood_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ainda não há registros.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use o botão acima ou o FAB do Início para o primeiro check-in.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: PulseColors.accent,
            onRefresh: () async {
              ref.invalidate(wellbeingUiSummaryProvider);
              await ref.read(wellbeingUiSummaryProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final log = logs[i];
                return _LogTile(log: log);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final WellbeingLog log;

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.fromMillisecondsSinceEpoch(log.loggedAtMs, isUtc: false);
    final dateStr = _historyDateFmt.format(dt);
    final timeStr = TimeOfDay.fromDateTime(dt).format(context);
    final note = log.note?.trim();
    final subtitle = StringBuffer('$dateStr · $timeStr');
    if (note != null && note.isNotEmpty) {
      final short = note.length > 80 ? '${note.substring(0, 77)}…' : note;
      subtitle.write('\n$short');
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.65,
          ),
      child: ListTile(
        title: Text('Humor ${log.mood}/5 · Energia ${log.energy}/5'),
        subtitle: Text(subtitle.toString()),
      ),
    );
  }
}
