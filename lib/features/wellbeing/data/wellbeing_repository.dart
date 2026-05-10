import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_outbox_writer.dart';

final class WellbeingRepository {
  WellbeingRepository(this._db);

  final PulseDatabase _db;
  final _uuid = const Uuid();

  Future<void> logCheckIn({
    required String userId,
    required int mood,
    required int energy,
    String? note,
    SyncOutboxWriter? syncOutbox,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.insertWellbeingLog(
      id: id,
      userId: userId,
      loggedAtMs: now,
      mood: mood,
      energy: energy,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    final log = WellbeingLog(
      id: id,
      userId: userId,
      loggedAtMs: now,
      mood: mood,
      energy: energy,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    await syncOutbox?.enqueueWellbeingUpsert(log);
  }
}
