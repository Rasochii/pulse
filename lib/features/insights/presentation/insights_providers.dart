import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../domain/insight_engine.dart';

final insightsListProvider =
    FutureProvider.autoDispose<List<InsightVm>>((ref) async {
  final uid =
      ref.watch(authUidStreamProvider).valueOrNull ??
          ref.watch(authRepositoryProvider).currentUser?.id;
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
  final moodsLogs = await db.wellbeingLogsForUser(uid, limit: 7);
  final moodsLast = moodsLogs.map((e) => e.mood).toList();
  return InsightEngine.generate(
    habits: habits,
    completions: comps,
    now: DateTime.now(),
    moodsLast7d: moodsLast.isEmpty ? null : moodsLast,
  );
});
