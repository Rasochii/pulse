import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeDarkNotifierProvider =
    NotifierProvider<ThemeDarkNotifier, bool>(ThemeDarkNotifier.new);

class ThemeDarkNotifier extends Notifier<bool> {
  static const _k = 'pulse_theme_dark';

  @override
  bool build() => true;

  Future<void> loadPersisted() async {
    final p = await SharedPreferences.getInstance();
    state = p.getBool(_k) ?? true;
  }

  Future<void> setDark(bool value) async {
    state = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_k, value);
  }
}
