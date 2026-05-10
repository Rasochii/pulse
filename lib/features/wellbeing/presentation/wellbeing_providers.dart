import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../data/wellbeing_repository.dart';

final wellbeingRepositoryProvider = Provider<WellbeingRepository>((ref) {
  return WellbeingRepository(ref.watch(pulseDatabaseProvider));
});
