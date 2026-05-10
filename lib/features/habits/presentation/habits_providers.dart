import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/database/app_database.dart';
import '../domain/habit_metrics.dart';
import '../data/habit_today_row.dart';

final habitsWatchProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final uid = ref.watch(authUidStreamProvider).valueOrNull;
  if (uid == null || uid.isEmpty) return Stream.value(<Habit>[]);
  return ref.watch(habitsRepositoryProvider).watchHabits(uid);
});

final todayHabitsProvider =
    FutureProvider.autoDispose<List<HabitTodayRow>>((ref) async {
  ref.watch(authUidStreamProvider);
  final uid = ref.watch(authUidStreamProvider).valueOrNull ??
      ref.watch(authRepositoryProvider).currentUser?.id;
  if (uid == null || uid.isEmpty) return [];
  return ref.watch(habitsRepositoryProvider).todayRows(uid, DateTime.now());
});

final habitMetricsProvider =
    FutureProvider.autoDispose.family<HabitMetrics, String>((ref, habitId) async {
  final habit = await ref.watch(habitsRepositoryProvider).habitById(habitId);
  if (habit == null) {
    return const HabitMetrics(
      currentStreak: 0,
      bestStreak: 0,
      completionRate30d: 0,
      completionsLast30d: 0,
      expectedDaysLast30d: 0,
    );
  }
  return ref.watch(habitsRepositoryProvider).metricsFor(habit);
});
