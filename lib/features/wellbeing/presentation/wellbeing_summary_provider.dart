import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../providers/app_providers.dart';
import '../domain/wellbeing_summary.dart';

/// Dados para o cartão do dashboard e a tela de histórico (uma leitura no SQLite).
final class WellbeingUiBundle {
  const WellbeingUiBundle({
    required this.summary,
    required this.logsNewestFirst,
  });

  final WellbeingUiSummary summary;
  final List<WellbeingLog> logsNewestFirst;
}

final wellbeingUiSummaryProvider =
    FutureProvider.autoDispose<WellbeingUiBundle>((ref) async {
  final uid = ref.watch(authUidStreamProvider).valueOrNull ??
      ref.watch(authRepositoryProvider).currentUser?.id;
  final db = ref.watch(pulseDatabaseProvider);

  if (uid == null || uid.isEmpty) {
    return WellbeingUiBundle(
      summary: WellbeingUiSummary.empty(),
      logsNewestFirst: const [],
    );
  }

  final logs = await db.wellbeingLogsForUser(uid, limit: 60);
  final habits = await db.habitsForUser(uid);
  final ids = habits.map((e) => e.id).toList();
  final completions =
      ids.isEmpty ? <HabitCompletion>[] : await db.completionsForUserHabits(ids);

  final summary = buildWellbeingUiSummary(
    logsNewestFirst: logs,
    habits: habits,
    completions: completions,
    now: DateTime.now(),
  );

  return WellbeingUiBundle(summary: summary, logsNewestFirst: logs);
});
