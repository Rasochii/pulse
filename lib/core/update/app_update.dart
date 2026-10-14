import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';

enum UpdateLevel {
  /// Versão em dia.
  none,

  /// Há versão mais nova; o usuário pode adiar.
  recommended,

  /// Versão abaixo do mínimo aceito: o app fica bloqueado até atualizar.
  required,
}

final class UpdateStatus {
  const UpdateStatus(this.level, {this.storeUrl, this.recommendedBuild = 0});

  static const upToDate = UpdateStatus(UpdateLevel.none);

  final UpdateLevel level;
  final String? storeUrl;

  /// Build recomendado — usado para não repetir o aviso já dispensado.
  final int recommendedBuild;
}

/// Compara o build instalado com os limites da tabela `app_config`.
/// `0` (ou menos) em [minBuild]/[recommendedBuild] desliga a regra.
UpdateLevel evaluateUpdate({
  required int currentBuild,
  required int minBuild,
  required int recommendedBuild,
}) {
  if (currentBuild <= 0) return UpdateLevel.none;
  if (minBuild > 0 && currentBuild < minBuild) return UpdateLevel.required;
  if (recommendedBuild > 0 && currentBuild < recommendedBuild) {
    return UpdateLevel.recommended;
  }
  return UpdateLevel.none;
}

/// Lê a versão mínima/recomendada no Supabase. Sem rede vale o último valor visto:
/// quem já sabia estar abaixo do mínimo continua bloqueado offline, mas a falta de
/// conexão sozinha nunca bloqueia o app.
class AppUpdateChecker {
  const AppUpdateChecker();

  static const _kMin = 'pulse_update_min_build';
  static const _kRecommended = 'pulse_update_recommended_build';
  static const _kStoreUrl = 'pulse_update_store_url';
  static const _kDismissed = 'pulse_update_dismissed_build';

  static String? get _platform {
    if (kIsWeb) return null; // A web já recebe a versão nova a cada deploy.
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
  }

  Future<UpdateStatus> check() async {
    final platform = _platform;
    if (platform == null || !AppEnv.hasSupabase) return UpdateStatus.upToDate;

    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;
    final prefs = await SharedPreferences.getInstance();

    var minBuild = prefs.getInt(_kMin) ?? 0;
    var recommendedBuild = prefs.getInt(_kRecommended) ?? 0;
    var storeUrl = prefs.getString(_kStoreUrl);
    try {
      final row = await Supabase.instance.client
          .from('app_config')
          .select('min_build, recommended_build, store_url')
          .eq('platform', platform)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
      minBuild = (row?['min_build'] as num?)?.toInt() ?? 0;
      recommendedBuild = (row?['recommended_build'] as num?)?.toInt() ?? 0;
      storeUrl = row?['store_url'] as String?;
      await prefs.setInt(_kMin, minBuild);
      await prefs.setInt(_kRecommended, recommendedBuild);
      if (storeUrl == null) {
        await prefs.remove(_kStoreUrl);
      } else {
        await prefs.setString(_kStoreUrl, storeUrl);
      }
    } catch (_) {
      // Sem rede ou tabela ausente: segue com o último valor conhecido.
    }

    var level = evaluateUpdate(
      currentBuild: currentBuild,
      minBuild: minBuild,
      recommendedBuild: recommendedBuild,
    );
    if (level == UpdateLevel.recommended &&
        (prefs.getInt(_kDismissed) ?? 0) >= recommendedBuild) {
      level = UpdateLevel.none;
    }

    return UpdateStatus(
      level,
      recommendedBuild: recommendedBuild,
      storeUrl: _nonEmpty(storeUrl) ??
          (platform == 'android'
              ? 'https://play.google.com/store/apps/details?id=${info.packageName}'
              : null),
    );
  }

  /// "Agora não" no aviso: não mostra de novo até sair um build recomendado maior.
  Future<void> dismissRecommended(int build) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDismissed, build);
  }

  static String? _nonEmpty(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();
}
