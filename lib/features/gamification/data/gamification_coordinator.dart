import '../../../core/analytics/analytics_gateway.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_outbox_writer.dart';
import '../../../core/utils/date_key.dart';
import '../../habits/domain/habit_metrics.dart';
import '../../habits/domain/habit_schedule.dart';

import '../domain/achievement_defs.dart';
import '../domain/level_curve.dart';

/// Hábitos e conclusões do usuário carregados uma vez, para avaliar regras em memória.
class _Snapshot {
  _Snapshot(this.habits, this.completions) {
    for (final c in completions) {
      byDay.putIfAbsent(c.dateKey, () => <String>{}).add(c.habitId);
      byHabit.putIfAbsent(c.habitId, () => <int>[]).add(c.dateKey);
    }
  }

  final List<Habit> habits;
  final List<HabitCompletion> completions;
  final byDay = <int, Set<String>>{};
  final byHabit = <String, List<int>>{};

  bool isPerfectDay(int dateKey) {
    final day = startOfDayFromDateKey(dateKey);
    final done = byDay[dateKey] ?? const <String>{};
    var expected = 0;
    for (final h in habits) {
      if (!isHabitExpectedOn(h, day)) continue;
      expected++;
      if (!done.contains(h.id)) return false;
    }
    return expected > 0;
  }

  HabitMetrics metricsFor(Habit h, DateTime now) => computeHabitMetrics(
        weekdaysBitmask: h.weekdaysBitmask,
        completionDateKeys: byHabit[h.id] ?? const [],
        now: now,
        createdAtMs: h.createdAtMs,
      );
}

/// Avalia XP e conquistas **após** marcar conclusão (Plano 4).
final class GamificationCoordinator {
  GamificationCoordinator(
    this._db, {
    AnalyticsGateway? analytics,
    SyncOutboxWriter? syncOutbox,
  })  : _analytics = analytics ?? const NoOpAnalyticsGateway(),
        _syncOutbox = syncOutbox;

  final PulseDatabase _db;
  final AnalyticsGateway _analytics;
  final SyncOutboxWriter? _syncOutbox;

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

  /// Retorna as chaves das conquistas desbloqueadas agora.
  Future<List<String>> onMarkedComplete({
    required String userId,
    required Habit habit,
    required DateTime day,
  }) async {
    await ensureProfile(userId);
    final nowDt = DateTime.now();
    final now = nowDt.millisecondsSinceEpoch;
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

    final habits = await _db.habitsForUser(userId);
    final snap = _Snapshot(
      habits,
      await _db.completionsForUserHabits(habits.map((e) => e.id)),
    );

    var xpGain = 15;
    if ((snap.byDay[keyToday]?.length ?? 0) <= 1) {
      xpGain += 5;
    }

    final metrics = snap.metricsFor(habit, nowDt);
    xpGain += metrics.currentStreak.clamp(0, 14) * 2;

    if (snap.isPerfectDay(keyToday)) {
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

    final already =
        (await _db.achievementsFor(userId)).map((u) => u.achievementKey).toSet();
    final unlocked = _unlockByRules(
      snap: snap,
      metrics: metrics,
      now: nowDt,
      totalXpAfter: total,
      newLevelAfter: newLevel,
    ).where((k) => !already.contains(k)).toList();

    for (final u in unlocked) {
      await _db.unlockAchievement(
        userId: userId,
        achievementKey: u,
        unlockedAtMs: now,
      );
      _analytics.logEvent('achievement_unlock', {'key': u});
    }
    await _syncOutbox?.enqueueGamificationSnapshot(userId);
    return unlocked;
  }

  /// Todas as conquistas cujas regras estão satisfeitas (inclui as já desbloqueadas).
  Set<String> _unlockByRules({
    required _Snapshot snap,
    required HabitMetrics metrics,
    required DateTime now,
    required int totalXpAfter,
    required int newLevelAfter,
  }) {
    final out = <String>{};
    final all = snap.completions;
    final habitCount = snap.habits.length;

    if (all.isNotEmpty) out.add(kAchFirstStep);

    if (all.length >= 10) out.add(kAchCompletions10);
    if (all.length >= 30) out.add(kAchCompletions30);
    if (all.length >= 100) out.add(kAchCompletions100);
    if (all.length >= 250) out.add(kAchCompletions250);

    if (metrics.currentStreak >= 3) out.add(kAchStreak3);
    if (metrics.currentStreak >= 7) out.add(kAchStreak7);
    if (metrics.currentStreak >= 14) out.add(kAchStreak14);
    if (metrics.currentStreak >= 30) out.add(kAchStreak30);

    var maxBest = 0;
    for (final h in snap.habits) {
      final best = snap.metricsFor(h, now).bestStreak;
      if (best > maxBest) maxBest = best;
    }
    if (maxBest >= 14) out.add(kAchBestStreakEver14);
    if (maxBest >= 30) out.add(kAchBestStreakEver30);

    if (habitCount >= 2) out.add(kAchHabitsTwo);
    if (habitCount >= 5) out.add(kAchHabitsFive);

    if (totalXpAfter >= 500) out.add(kAchXp500);
    if (totalXpAfter >= 2000) out.add(kAchXp2000);

    if (newLevelAfter >= 5) out.add(kAchLevel5);
    if (newLevelAfter >= 10) out.add(kAchLevel10);

    final perfectTotal = snap.byDay.keys.where(snap.isPerfectDay).length;
    if (perfectTotal >= 3) out.add(kAchPerfectDays3);
    if (perfectTotal >= 10) out.add(kAchPerfectDays10);

    if (snap.isPerfectDay(dateKeyFromDateTime(now))) {
      out.add(kAchPerfectDay);
    }

    if (all.any((c) => _hourOf(c) < 8)) out.add(kAchEarlyBird);
    if (all.any((c) => _hourOf(c) >= 22)) out.add(kAchNightOwl);

    return out;
  }

  int _hourOf(HabitCompletion c) =>
      DateTime.fromMillisecondsSinceEpoch(c.completedAtMs, isUtc: false).hour;
}
