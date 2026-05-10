import 'package:shared_preferences/shared_preferences.dart';

/// Marcos `updated_at_ms` remotos por tabela para pull incremental (LWW — Plano 8).
final class SyncWatermarkStore {
  static const _kHabits = 'pulse_sync_wm_habits_ms';
  static const _kCompletions = 'pulse_sync_wm_completions_ms';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<int> habitsWatermarkMs() async {
    final p = await _prefs();
    return p.getInt(_kHabits) ?? 0;
  }

  Future<void> setHabitsWatermarkMs(int ms) async {
    final p = await _prefs();
    await p.setInt(_kHabits, ms);
  }

  Future<int> completionsWatermarkMs() async {
    final p = await _prefs();
    return p.getInt(_kCompletions) ?? 0;
  }

  Future<void> setCompletionsWatermarkMs(int ms) async {
    final p = await _prefs();
    await p.setInt(_kCompletions, ms);
  }

  Future<void> clearAll() async {
    final p = await _prefs();
    await p.remove(_kHabits);
    await p.remove(_kCompletions);
  }
}
