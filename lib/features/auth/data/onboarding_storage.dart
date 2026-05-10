import 'package:shared_preferences/shared_preferences.dart';

const _keyPrefix = 'pulse_onboarding_done_';

Future<bool> isOnboardingDoneForUser(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('$_keyPrefix$userId') ?? false;
}

Future<void> setOnboardingDoneForUser(String userId, {bool done = true}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('$_keyPrefix$userId', done);
}

Future<void> clearOnboardingForUser(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('$_keyPrefix$userId');
}
