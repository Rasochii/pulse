import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';
import '../database/app_database.dart';
import 'sync_watermark_store.dart';

/// Push da outbox + pull incremental com **LWW por `updated_at_ms`/`completed_at_ms`**.
final class PulseSyncEngine {
  PulseSyncEngine(
    this._db,
    this._watermarks,
  );

  final PulseDatabase _db;
  final SyncWatermarkStore _watermarks;

  Future<bool> _isOnline() async {
    final r = await Connectivity().checkConnectivity();
    if (r.isEmpty) return true;
    return !r.contains(ConnectivityResult.none);
  }

  Future<void> bootstrap(String userId) async {
    if (!AppEnv.hasSupabase) return;
    await flushOutbox(userId);
    await pullRemote(userId);
  }

  Future<void> flushOutbox(String userId) async {
    if (!AppEnv.hasSupabase || !await _isOnline()) return;
    final pending = await _db.pendingOutbox(limit: 80);
    final client = Supabase.instance.client;

    for (final row in pending) {
      try {
        if (row.entity == 'habit' && row.op == 'upsert') {
          final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
          if ((map['user_id'] as String?) != userId) {
            await _db.deleteOutbox(row.id);
            continue;
          }
          await client.from('pulse_habits').upsert(map);
        } else if (row.entity == 'habit_completion' && row.op == 'upsert') {
          final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
          await client.from('pulse_habit_completions').upsert(map);
        } else if (row.entity == 'habit_completion' && row.op == 'delete') {
          final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
          await client
              .from('pulse_habit_completions')
              .delete()
              .eq('habit_id', map['habit_id'] as String)
              .eq('date_key', map['date_key'] as int);
        } else if (row.entity == 'wellbeing_log' && row.op == 'upsert') {
          final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
          if ((map['user_id'] as String?) != userId) {
            await _db.deleteOutbox(row.id);
            continue;
          }
          await client.from('pulse_wellbeing_logs').upsert(map);
        } else {
          await _db.deleteOutbox(row.id);
          continue;
        }
        await _db.deleteOutbox(row.id);
      } catch (e) {
        final next = row.attempts + 1;
        await _db.markOutboxFailure(row.id, e.toString(), next);
      }
    }
  }

  Future<void> pullRemote(String userId) async {
    if (!AppEnv.hasSupabase || !await _isOnline()) return;
    final client = Supabase.instance.client;

    final wmHabits = await _watermarks.habitsWatermarkMs();
    final habitsResp = await client
        .from('pulse_habits')
        .select()
        .eq('user_id', userId)
        .gt('updated_at_ms', wmHabits)
        .order('updated_at_ms');

    final habitRows =
        List<Map<String, dynamic>>.from(habitsResp as List? ?? []);

    var maxHm = wmHabits;
    for (final raw in habitRows) {
      final row = Map<String, dynamic>.from(raw);
      final id = row['id'] as String?;
      if (id == null) continue;
      final ru = row['updated_at_ms'] as int? ?? 0;
      maxHm = maxHm > ru ? maxHm : ru;
      await _mergeHabitFromRemote(row);
    }
    if (habitRows.isNotEmpty) {
      await _watermarks.setHabitsWatermarkMs(maxHm);
    }

    final wmC = await _watermarks.completionsWatermarkMs();
    final cmpResp = await client
        .from('pulse_habit_completions')
        .select()
        .gt('completed_at_ms', wmC);

    final cRows =
        List<Map<String, dynamic>>.from(cmpResp as List? ?? []);
    var maxC = wmC;
    for (final raw in cRows) {
      final row = Map<String, dynamic>.from(raw);
      final habitId = row['habit_id'] as String?;
      if (habitId == null) continue;
      final local = await _db.habitById(habitId);
      if (local?.userId != userId) continue;
      final at = row['completed_at_ms'] as int? ?? 0;
      maxC = maxC > at ? maxC : at;
      final dateKey = row['date_key'] as int? ?? 0;
      await _mergeCompletionFromRemote(
        habitId: habitId,
        dateKey: dateKey,
        completedAtMs: at,
        quantity: (row['quantity'] as num?)?.toDouble() ?? 1,
      );
    }
    if (cRows.isNotEmpty) {
      await _watermarks.setCompletionsWatermarkMs(maxC);
    }
  }

  Future<void> _mergeHabitFromRemote(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final ru = row['updated_at_ms'] as int? ?? 0;
    final local = await _db.habitById(id);
    if (local != null && local.updatedAtMs > ru) return;

    final userId = row['user_id'] as String? ?? local?.userId ?? '';
    final nameRaw = row['name'] as String?;
    final name =
        nameRaw?.trim().isNotEmpty == true ? nameRaw!.trim() : (local?.name ?? 'Hábito');

    final created = (row['created_at_ms'] as int?) ?? local?.createdAtMs ?? ru;
    final desc = row['description'] as String?;
    final cat = row['category'] as String?;
    final icon = row['icon_key'] as String? ?? 'task_alt';
    final color = (row['color_argb'] as int?) ?? local?.colorArgb ?? 0xFF7C83FF;
    final mask = (row['weekdays_bitmask'] as int?) ?? local?.weekdaysBitmask ?? 127;

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
          reminderHour: Value(row['reminder_hour'] as int?),
          reminderMinute: Value(row['reminder_minute'] as int?),
          dailyTarget: Value(
            (row['daily_target'] as num?)?.toDouble() ?? 1,
          ),
          dailyTargetUnit: Value(row['daily_target_unit'] as String?),
          reminderTimesJson: Value(row['reminder_times_json'] as String?),
          createdAtMs: created,
          updatedAtMs: ru,
          deletedAtMs: Value(row['deleted_at_ms'] as int?),
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
          reminderHour: Value(row['reminder_hour'] as int?),
          reminderMinute: Value(row['reminder_minute'] as int?),
          dailyTarget: Value(
            (row['daily_target'] as num?)?.toDouble() ?? local.dailyTarget,
          ),
          dailyTargetUnit: Value(row['daily_target_unit'] as String?),
          reminderTimesJson: Value(row['reminder_times_json'] as String?),
          createdAtMs: Value(created),
          updatedAtMs: Value(ru),
          deletedAtMs: Value(row['deleted_at_ms'] as int?),
        ),
      );
    }
  }

  Future<void> _mergeCompletionFromRemote({
    required String habitId,
    required int dateKey,
    required int completedAtMs,
    required double quantity,
  }) async {
    final rows = await _db.completionRow(habitId, dateKey);
    if (rows != null && rows.completedAtMs >= completedAtMs) return;

    await _db.setCompletion(
      habitId: habitId,
      dateKey: dateKey,
      completedAtMs: completedAtMs,
      quantity: quantity,
    );
  }
}
