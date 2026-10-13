import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';
import '../database/app_database.dart';
import '../../features/gamification/domain/level_curve.dart';
import 'sync_outbox_writer.dart';
import 'sync_watermark_store.dart';

/// Push da outbox + pull incremental com **LWW por `updated_at_ms`/`completed_at_ms`**.
final class PulseSyncEngine {
  PulseSyncEngine(
    this._db,
    this._watermarks,
  );

  /// Rejeições do servidor antes de o item sair da fila ativa.
  static const maxAttempts = 8;
  static const _outboxBatch = 500;

  final PulseDatabase _db;
  final SyncWatermarkStore _watermarks;

  Future<void>? _flushInFlight;
  bool _flushAgain = false;

  Future<bool> _isOnline() async {
    final r = await Connectivity().checkConnectivity();
    if (r.isEmpty) return true;
    return !r.contains(ConnectivityResult.none);
  }

  /// Só sincroniza para o usuário da sessão Supabase atual (o modo local não tem nuvem).
  bool _canSync(String userId) {
    if (!AppEnv.hasSupabase) return false;
    return Supabase.instance.client.auth.currentUser?.id == userId;
  }

  Future<void> bootstrap(String userId) async {
    if (!_canSync(userId)) return;
    await flushOutbox(userId);
    await pullRemote(userId);
  }

  /// Dá nova chance aos itens que esgotaram [maxAttempts] (chamar ao abrir o app).
  Future<void> retryFailed() => _db.resetOutboxAttempts();

  /// Envia a fila. Chamadas concorrentes são fundidas numa só execução.
  Future<void> flushOutbox(String userId) {
    final running = _flushInFlight;
    if (running != null) {
      _flushAgain = true;
      return running;
    }
    final run = _runFlush(userId).whenComplete(() => _flushInFlight = null);
    _flushInFlight = run;
    return run;
  }

  Future<void> _runFlush(String userId) async {
    do {
      _flushAgain = false;
      await _flushOnce(userId);
    } while (_flushAgain);
  }

  Future<void> _flushOnce(String userId) async {
    if (!_canSync(userId) || !await _isOnline()) return;
    final client = Supabase.instance.client;

    while (true) {
      final pending = await _db.pendingOutbox(
        limit: _outboxBatch,
        maxAttempts: maxAttempts,
      );
      var sent = 0;

      for (final row in pending) {
        try {
          final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
          final owner = await _ownerOf(row.entity, map);
          if (owner == null) {
            // Órfão (ex.: hábito já removido do aparelho).
            await _db.deleteOutbox(row.id);
            continue;
          }
          // De outra conta: fica na fila até essa conta entrar de novo.
          if (owner != userId) continue;

          if (row.entity == 'habit' && row.op == 'upsert') {
            await client.from('pulse_habits').upsert(map);
          } else if (row.entity == 'habit_completion' && row.op == 'upsert') {
            map['updated_at_ms'] ??= map['completed_at_ms'];
            map['deleted_at_ms'] = null;
            await client.from('pulse_habit_completions').upsert(map);
          } else if (row.entity == 'habit_completion' && row.op == 'delete') {
            final deletedAt =
                (map['deleted_at_ms'] as num?)?.toInt() ?? row.createdAtMs;
            await client.from('pulse_habit_completions').upsert({
              'habit_id': map['habit_id'],
              'date_key': map['date_key'],
              'completed_at_ms': deletedAt,
              'quantity': 0,
              'updated_at_ms': deletedAt,
              'deleted_at_ms': deletedAt,
            });
          } else if (row.entity == 'wellbeing_log' && row.op == 'upsert') {
            await client.from('pulse_wellbeing_logs').upsert(map);
          } else if (row.entity == 'gamification' && row.op == 'upsert') {
            await client.from('pulse_gamification').upsert(map);
          }
          await _db.deleteOutbox(row.id);
          sent++;
        } on PostgrestException catch (e) {
          // O servidor rejeitou este item: conta a tentativa e segue com os demais.
          await _db.markOutboxFailure(row.id, e.message, row.attempts + 1);
        } catch (e) {
          // Rede/timeout: os próximos falhariam igual — tenta de novo no próximo flush.
          await _db.markOutboxFailure(row.id, e.toString(), row.attempts);
          return;
        }
      }

      if (pending.length < _outboxBatch || sent == 0) return;
    }
  }

  Future<String?> _ownerOf(String entity, Map<String, dynamic> map) async {
    if (entity == 'habit_completion') {
      final habitId = map['habit_id'] as String?;
      if (habitId == null) return null;
      return (await _db.habitById(habitId))?.userId;
    }
    return map['user_id'] as String?;
  }

  /// Busca todas as linhas com `column > watermark`, em páginas, em ordem estável.
  Future<List<Map<String, dynamic>>> _fetchSince({
    required String table,
    required String column,
    required int watermark,
    required List<String> tieBreak,
    String? userId,
  }) async {
    final client = Supabase.instance.client;
    final out = <Map<String, dynamic>>[];
    while (true) {
      var filter = client.from(table).select().gt(column, watermark);
      if (userId != null) filter = filter.eq('user_id', userId);
      var ordered = filter.order(column, ascending: true);
      for (final c in tieBreak) {
        ordered = ordered.order(c, ascending: true);
      }
      final page = await ordered.range(out.length, out.length + 999);
      if (page.isEmpty) break;
      out.addAll(page);
    }
    return out;
  }

  static int _int(Object? v, [int fallback = 0]) =>
      (v as num?)?.toInt() ?? fallback;

  Future<void> pullRemote(String userId) async {
    if (!_canSync(userId) || !await _isOnline()) return;

    await _pullHabits(userId);
    await _pullCompletions(userId);
    await _pullWellbeing(userId);
    await _pullGamification(userId);
  }

  Future<void> _pullHabits(String userId) async {
    final wm = await _watermarks.habitsWatermarkMs(userId);
    final rows = await _fetchSince(
      table: 'pulse_habits',
      column: 'updated_at_ms',
      watermark: wm,
      tieBreak: const ['id'],
      userId: userId,
    );
    var max = wm;
    for (final row in rows) {
      if (row['id'] is! String) continue;
      final ru = _int(row['updated_at_ms']);
      if (ru > max) max = ru;
      await _mergeHabitFromRemote(row);
    }
    if (max > wm) await _watermarks.setHabitsWatermarkMs(userId, max);
  }

  Future<void> _pullCompletions(String userId) async {
    final wm = await _watermarks.completionsWatermarkMs(userId);
    // O RLS já restringe às conclusões dos hábitos do usuário.
    final rows = await _fetchSince(
      table: 'pulse_habit_completions',
      column: 'updated_at_ms',
      watermark: wm,
      tieBreak: const ['habit_id', 'date_key'],
    );
    var max = wm;
    for (final row in rows) {
      final habitId = row['habit_id'] as String?;
      if (habitId == null) continue;
      final local = await _db.habitById(habitId);
      if (local?.userId != userId) continue;

      final updatedAt = _int(row['updated_at_ms']);
      if (updatedAt > max) max = updatedAt;
      final dateKey = _int(row['date_key']);

      final deletedAt = (row['deleted_at_ms'] as num?)?.toInt();
      if (deletedAt != null) {
        final current = await _db.completionRow(habitId, dateKey);
        if (current != null && current.completedAtMs <= deletedAt) {
          await _db.deleteCompletion(habitId, dateKey);
        }
        continue;
      }

      await _mergeCompletionFromRemote(
        habitId: habitId,
        dateKey: dateKey,
        completedAtMs: _int(row['completed_at_ms']),
        quantity: (row['quantity'] as num?)?.toDouble() ?? 1,
      );
    }
    if (max > wm) await _watermarks.setCompletionsWatermarkMs(userId, max);
  }

  Future<void> _pullWellbeing(String userId) async {
    final wm = await _watermarks.wellbeingWatermarkMs(userId);
    final rows = await _fetchSince(
      table: 'pulse_wellbeing_logs',
      column: 'logged_at_ms',
      watermark: wm,
      tieBreak: const ['id'],
      userId: userId,
    );
    var max = wm;
    for (final row in rows) {
      final id = row['id'] as String?;
      if (id == null) continue;
      final at = _int(row['logged_at_ms']);
      if (at > max) max = at;
      await _db.upsertWellbeingLog(
        WellbeingLogsCompanion.insert(
          id: id,
          userId: userId,
          loggedAtMs: at,
          mood: _int(row['mood'], 3),
          energy: _int(row['energy'], 3),
          note: Value(row['note'] as String?),
        ),
      );
    }
    if (max > wm) await _watermarks.setWellbeingWatermarkMs(userId, max);
  }

  /// XP: vence o maior total. Conquistas: união dos dois lados.
  Future<void> _pullGamification(String userId) async {
    final client = Supabase.instance.client;
    final remote = await client
        .from('pulse_gamification')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    final local = await _db.gamificationForUser(userId);
    final localKeys =
        (await _db.achievementsFor(userId)).map((u) => u.achievementKey).toSet();

    var remoteXp = 0;
    final remoteAch = <String, int>{};
    if (remote != null) {
      remoteXp = _int(remote['total_xp']);
      final raw = remote['achievements'];
      if (raw is Map) {
        raw.forEach((k, v) => remoteAch['$k'] = _int(v));
      }
      if (remoteXp > (local?.totalXp ?? 0)) {
        await _db.upsertGamificationProfile(
          userId: userId,
          totalXp: remoteXp,
          level: computeLevelFromTotalXp(remoteXp),
          updatedAtMs: _int(remote['updated_at_ms']),
        );
      }
      for (final entry in remoteAch.entries) {
        if (localKeys.contains(entry.key)) continue;
        await _db.unlockAchievement(
          userId: userId,
          achievementKey: entry.key,
          unlockedAtMs: entry.value,
        );
      }
    }

    final localAhead = (local?.totalXp ?? 0) > remoteXp ||
        localKeys.any((k) => !remoteAch.containsKey(k));
    if (localAhead) {
      final payload = await buildGamificationPayload(_db, userId);
      if (payload != null) {
        await client.from('pulse_gamification').upsert(payload);
      }
    }
  }

  Future<void> _mergeHabitFromRemote(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final ru = _int(row['updated_at_ms']);
    final local = await _db.habitById(id);
    if (local != null && local.updatedAtMs > ru) return;

    final userId = row['user_id'] as String? ?? local?.userId ?? '';
    final nameRaw = row['name'] as String?;
    final name =
        nameRaw?.trim().isNotEmpty == true ? nameRaw!.trim() : (local?.name ?? 'Hábito');

    final created =
        (row['created_at_ms'] as num?)?.toInt() ?? local?.createdAtMs ?? ru;
    final desc = row['description'] as String?;
    final cat = row['category'] as String?;
    final icon = row['icon_key'] as String? ?? 'task_alt';
    final color =
        (row['color_argb'] as num?)?.toInt() ?? local?.colorArgb ?? 0xFF7C83FF;
    final mask = (row['weekdays_bitmask'] as num?)?.toInt() ??
        local?.weekdaysBitmask ??
        127;
    final reminderHour = (row['reminder_hour'] as num?)?.toInt();
    final reminderMinute = (row['reminder_minute'] as num?)?.toInt();
    final deletedAt = (row['deleted_at_ms'] as num?)?.toInt();

    if (local == null) {
      await _db.insertHabit(
        HabitsCompanion.insert(
          id: id,
          userId: userId,
          name: name,
          description: Value(desc),
          category: Value(cat),
          iconKey: Value(icon),
          colorArgb: Value(color),
          weekdaysBitmask: Value(mask),
          reminderHour: Value(reminderHour),
          reminderMinute: Value(reminderMinute),
          dailyTarget: Value(
            (row['daily_target'] as num?)?.toDouble() ?? 1,
          ),
          dailyTargetUnit: Value(row['daily_target_unit'] as String?),
          reminderTimesJson: Value(row['reminder_times_json'] as String?),
          createdAtMs: created,
          updatedAtMs: ru,
          deletedAtMs: Value(deletedAt),
        ),
      );
    } else {
      await _db.updateHabit(
        HabitsCompanion(
          id: Value(id),
          userId: Value(userId),
          name: Value(name),
          description: Value(desc),
          category: Value(cat),
          iconKey: Value(icon),
          colorArgb: Value(color),
          weekdaysBitmask: Value(mask),
          reminderHour: Value(reminderHour),
          reminderMinute: Value(reminderMinute),
          dailyTarget: Value(
            (row['daily_target'] as num?)?.toDouble() ?? local.dailyTarget,
          ),
          dailyTargetUnit: Value(row['daily_target_unit'] as String?),
          reminderTimesJson: Value(row['reminder_times_json'] as String?),
          createdAtMs: Value(created),
          updatedAtMs: Value(ru),
          deletedAtMs: Value(deletedAt),
        ),
      );
    }
  }

  /// LWW por `completedAtMs`; no empate vale a maior quantidade (ex.: meta reajustada).
  Future<void> _mergeCompletionFromRemote({
    required String habitId,
    required int dateKey,
    required int completedAtMs,
    required double quantity,
  }) async {
    final row = await _db.completionRow(habitId, dateKey);
    if (row != null) {
      if (row.completedAtMs > completedAtMs) return;
      if (row.completedAtMs == completedAtMs && row.quantity >= quantity) {
        return;
      }
    }

    await _db.setCompletion(
      habitId: habitId,
      dateKey: dateKey,
      completedAtMs: completedAtMs,
      quantity: quantity,
    );
  }
}
