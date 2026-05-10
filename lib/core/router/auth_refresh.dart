import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';

/// Notifica o GoRouter quando a sessão Supabase muda.
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(AuthRepository auth) {
    if (!auth.canUseSupabase) return;
    _sub = auth.authStateChanges.listen((_) => notifyListeners());
  }

  StreamSubscription<dynamic>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
