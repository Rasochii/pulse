import '../../../core/analytics/analytics_gateway.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_key.dart';
import '../../habits/domain/habit_metrics.dart';

import '../domain/achievement_defs.dart';
import '../domain/level_curve.dart';

/// Avalia XP e conquistas **após** marcar conclusão (Plano 4).
final class GamificationCoordinator {
  GamificationCoordinator(
    this._db, {
    AnalyticsGateway? analytics,
  }) : _analytics = analytics ?? const NoOpAnalyticsGateway();

  final PulseDatabase _db;
  final AnalyticsGateway _analytics;

  Future<void> ensureProfile(String userId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final row = await _db.gamificationForUser(userId);
    if (row == null) {
      await _db.upsertGamificationProfile(
        userId: userId,
        totalXp: 0,
        level: 1,
        updatedAtMs: now,
      );
    }
  }

  Future<List<String>> onMarkedComplete({
    required String userId,
    required Habit habit,
    required DateTime day,
  }) async {
    await ensureProfile(userId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final current = await _db.gamificationForUser(userId);
    if (current == null) return [];

    final keyToday = dateKeyFromDateTime(day);
    if (await _db.hasHabitXpClaim(
      userId: userId,
      habitId: habit.id,
      dateKey: keyToday,
    )) {
      return [];
    }

    var xpGain = 15;
    final completionsToday = await _completionsCountOnDate(userId, keyToday);
    if (completionsToday <= 1) {
      xpGain += 5;
    }

    final habitRows = await _db.completionsForHabit(habit.id);
    final keys = habitRows.map((r) => r.dateKey).toList();
    final metrics = computeHabitMetrics(
      weekdaysBitmask: habit.weekdaysBitmask,
      completionDateKeys: keys,
      now: DateTime.now(),
    );
    xpGain += metrics.currentStreak.clamp(0, 14) * 2;

    if (await _isPerfectDay(userId, keyToday)) {
      xpGain += 12;
      _analytics.logEvent('perfect_day_bonus', {'date_key': keyToday});
    }

    final total = current.totalXp + xpGain;
    final newLevel = computeLevelFromTotalXp(total);
    await _db.upsertGamificationProfile(
      userId: userId,
      totalXp: total,
      level: newLevel,
      updatedAtMs: now,
    );
    await _db.insertHabitXpClaim(
      userId: userId,
      habitId: habit.id,
      dateKey: keyToday,
      claimedAtMs: now,
    );
    _analytics.logEvent(
      'xp_gain',
      {'delta': xpGain, 'total': total, 'level': newLevel},
    );

    final unlocked = await _unlockByRules(
      userId: userId,
      metrics: metrics,
      totalXpAfter: total,
      newLevelAfter: newLevel,
    );
    for (final u in unlocked) {
      await _db.unlockAchievement(
        userId: userId,
        achievementKey: u,
        unlockedAtMs: now,
      );
      _analytics.logEvent('achievement_unlock', {'key': u});
    }
    return unlocked;
  }

  Future<int> _completionsCountOnDate(String userId, int dateKey) async {
    final ids = (await _db.habitsForUser(userId)).map((e) => e.id);
    final rows = await _db.completionsForUserHabits(ids);
    return rows.where((c) => c.dateKey == dateKey).length;
  }

  Future<bool> _isPerfectDay(String userId, int dateKey) async {
    final d = DateTime(
      dateKey ~/ 10000,
      (dateKey % 10000) ~/ 100,
      dateKey % 100,
    );
    final scheduled = await _db.habitsScheduledForDay(userId, d);
    if (scheduled.isEmpty) return false;
    for (final h in scheduled) {
      if (!await _db.hasCompletion(h.id, dateKey)) return false;
    }
    return true;
  }

  Future<List<String>> _unlockByRules({
    required String userId,
    required HabitMetrics metrics,
    required int totalXpAfter,
    required int newLevelAfter,
  }) async {
    final out = <String>[];
    final habits = await _db.habitsForUser(userId);
    final ids = habits.map((e) => e.id).toList();
    final all = ids.isEmpty ? <HabitCompletion>[] : await _db.completionsForUserHabits(ids);
    final habitCount = habits.length;

    Future<void> tryUnlock(String key) async {
      if (await _db.hasAchievement(userId, key)) return;
      if (!out.contains(key)) out.add(key);
    }

    if (all.isNotEmpty) await tryUnlock(kAchFirstStep);

    if (all.length >= 10) await tryUnlock(kAchCompletions10);
    if (all.length >= 30) await tryUnlock(kAchCompletions30);
    if (all.length >= 100) await tryUnlock(kAchCompletions100);
    if (all.length >= 250) await tryUnlock(kAchCompletions250);

    if (metrics.currentStreak >= 3) await tryUnlock(kAchStreak3);
    if (metrics.currentStreak >= 7) await tryUnlock(kAchStreak7);
    if (metrics.currentStreak >= 14) await tryUnlock(kAchStreak14);
    if (metrics.currentStreak >= 30) await tryUnlock(kAchStreak30);

    final maxBest = await _maxBestStreakAnyHabit(userId);
    if (maxBest >= 14) await tryUnlock(kAchBestStreakEver14);
    if (maxBest >= 30) await tryUnlock(kAchBestStreakEver30);

    if (habitCount >= 2) await tryUnlock(kAchHabitsTwo);
    if (habitCount >= 5) await tryUnlock(kAchHabitsFive);

    if (totalXpAfter >= 500) await tryUnlock(kAchXp500);
    if (totalXpAfter >= 2000) await tryUnlock(kAchXp2000);

    if (newLevelAfter >= 5) await tryUnlock(kAchLevel5);
    if (newLevelAfter >= 10) await tryUnlock(kAchLevel10);

    final dateKeys = all.map((c) => c.dateKey).toSet();
    var perfectTotal = 0;
    for (final key in dateKeys) {
      if (await _isPerfectDay(userId, key)) perfectTotal++;
    }
    if (perfectTotal >= 3) await tryUnlock(kAchPerfectDays3);
    if (perfectTotal >= 10) await tryUnlock(kAchPerfectDays10);

    final todayKey = dateKeyFromDateTime(DateTime.now());
    if (await _isPerfectDay(userId, todayKey)) {
      await tryUnlock(kAchPerfectDay);
    }

    if (_hasCompletionBeforeHour(all, 8)) await tryUnlock(kAchEarlyBird);
    if (_hasCompletionAtOrAfterHour(all, 22)) await tryUnlock(kAchNightOwl);

    return out;
  }

  Future<int> _maxBestStreakAnyHabit(String userId) async {
    final habits = await _db.habitsForUser(userId);
    final now = DateTime.now();
    var maxBest = 0;
    for (final h in habits) {
      final rows = await _db.completionsForHabit(h.id);
      final keys = rows.map((r) => r.dateKey).toList();
      final m = computeHabitMetrics(
        weekdaysBitmask: h.weekdaysBitmask,
        completionDateKeys: keys,
        now: now,
      );
      if (m.bestStreak > maxBest) maxBest = m.bestStreak;
    }
    return maxBest;
  }

  bool _hasCompletionBeforeHour(List<HabitCompletion> all, int hourEndExclusive) {
    for (final c in all) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        c.completedAtMs,
        isUtc: false,
      );
      if (dt.hour < hourEndExclusive) return true;
    }
    return false;
  }

  bool _hasCompletionAtOrAfterHour(List<HabitCompletion> all, int hourMinInclusive) {
    for (final c in all) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        c.completedAtMs,
        isUtc: false,
      );
      if (dt.hour >= hourMinInclusive) return true;
    }
    return false;
  }
}
