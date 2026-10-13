import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../domain/insight_engine.dart';

final insightsListProvider =
    FutureProvider.autoDispose<List<InsightVm>>((ref) async {
  final uid =
      ref.watch(authUidStreamProvider).valueOrNull ??
          ref.watch(authRepositoryProvider).currentUserId;
  final db = ref.watch(pulseDatabaseProvider);
  if (uid == null || uid.isEmpty) {
    return InsightEngine.generate(
      habits: const [],
      completions: const [],
      now: DateTime.now(),
    );
  }
  final habits = await db.habitsForUser(uid);
  final ids = habits.map((e) => e.id).toList();
  final comps = await db.completionsForUserHabits(ids);
  final now = DateTime.now();
  // Só os check-ins dos últimos 7 dias: registros antigos não descrevem a fase atual.
  final since = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;
  final moodsLast = (await db.wellbeingLogsForUser(uid))
      .where((e) => e.loggedAtMs >= since)
      .map((e) => e.mood)
      .toList();
  return InsightEngine.generate(
    habits: habits,
    completions: comps,
    now: now,
    moodsLast7d: moodsLast.isEmpty ? null : moodsLast,
  );
});
