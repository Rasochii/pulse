import 'package:shared_preferences/shared_preferences.dart';

/// Marcos remotos por tabela **e por usuário** para pull incremental (LWW — Plano 8).
final class SyncWatermarkStore {
  static const _kHabits = 'pulse_sync_wm_habits_ms';
  static const _kCompletions = 'pulse_sync_wm_completions_ms';
  static const _kWellbeing = 'pulse_sync_wm_wellbeing_ms';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<int> _get(String key, String userId) async {
    final p = await _prefs();
    return p.getInt('${key}_$userId') ?? 0;
  }

  Future<void> _set(String key, String userId, int ms) async {
    final p = await _prefs();
    await p.setInt('${key}_$userId', ms);
  }

  Future<int> habitsWatermarkMs(String userId) => _get(_kHabits, userId);

  Future<void> setHabitsWatermarkMs(String userId, int ms) =>
      _set(_kHabits, userId, ms);

  Future<int> completionsWatermarkMs(String userId) =>
      _get(_kCompletions, userId);

  Future<void> setCompletionsWatermarkMs(String userId, int ms) =>
      _set(_kCompletions, userId, ms);

  Future<int> wellbeingWatermarkMs(String userId) => _get(_kWellbeing, userId);

  Future<void> setWellbeingWatermarkMs(String userId, int ms) =>
      _set(_kWellbeing, userId, ms);

  Future<void> clearAll(String userId) async {
    final p = await _prefs();
    for (final key in [_kHabits, _kCompletions, _kWellbeing]) {
      await p.remove('${key}_$userId');
    }
  }
}
