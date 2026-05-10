import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/database/app_database.dart';

final gamificationProfileProvider =
    FutureProvider.autoDispose<GamificationProfile?>((ref) async {
  final uid =
      ref.watch(authUidStreamProvider).valueOrNull ??
          ref.watch(authRepositoryProvider).currentUser?.id;
  if (uid == null || uid.isEmpty) return null;
  final db = ref.watch(pulseDatabaseProvider);
  return db.gamificationForUser(uid);
});

final unlockedAchievementsProvider =
    FutureProvider.autoDispose<List<UserAchievementUnlock>>((ref) async {
  final uid =
      ref.watch(authUidStreamProvider).valueOrNull ??
          ref.watch(authRepositoryProvider).currentUser?.id;
  if (uid == null || uid.isEmpty) return [];
  return ref.watch(pulseDatabaseProvider).achievementsFor(uid);
});
