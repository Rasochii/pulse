import 'package:url_launcher/url_launcher.dart';

/// Páginas públicas do Pulse, publicadas com a versão web (pasta `web/`).
abstract final class AppLinks {
  static const _base = 'https://rasochii.github.io/pulse';

  static const privacyPolicy = '$_base/privacidade.html';
  static const accountDeletion = '$_base/excluir-conta.html';
}

/// Abre o link no navegador do aparelho; falha em silêncio (sem navegador).
Future<void> openExternalLink(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
}
