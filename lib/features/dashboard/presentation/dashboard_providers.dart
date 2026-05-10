import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../domain/dashboard_snapshot.dart';

final dashboardSnapshotProvider =
    FutureProvider.autoDispose<DashboardSnapshot>((ref) async {
  ref.watch(authUidStreamProvider);
  ref.watch(authRepositoryProvider);
  final uid =
      ref.watch(authUidStreamProvider).valueOrNull ??
          ref.watch(authRepositoryProvider).currentUser?.id ??
          '';
  if (uid.isEmpty) {
    return DashboardSnapshot.empty('aí');
  }
  final rawName =
      ref.watch(authRepositoryProvider).currentUser?.userMetadata?['full_name']
          as String?;
  final displayName = _firstNameOnly(rawName);
  return ref.watch(habitsRepositoryProvider).dashboardSnapshot(
        userId: uid,
        now: DateTime.now(),
        displayName: displayName,
      );
});

String? _firstNameOnly(String? fullName) {
  final t = fullName?.trim();
  if (t == null || t.isEmpty) return null;
  return t.split(RegExp(r'\s+')).first;
}
