import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_env.dart';

/// Relatório de falhas (Sentry). Só no build release e com `SENTRY_DSN`;
/// sem isso o app roda normalmente, sem enviar nada.
bool get crashReportingEnabled => AppEnv.hasSentry && kReleaseMode;

/// Inicia o Sentry e roda o app dentro dele (erros não tratados de Flutter,
/// Dart e nativos são enviados).
Future<void> runWithCrashReporting(Future<void> Function() appRunner) async {
  if (!crashReportingEnabled) return appRunner();
  await SentryFlutter.init(configureCrashReporting, appRunner: appRunner);
}

@visibleForTesting
void configureCrashReporting(SentryFlutterOptions o) {
  o.dsn = AppEnv.sentryDsn;
  // Só falhas: sem desempenho, para a cota gratuita ir toda para erros.
  o.tracesSampleRate = null;
  o.enableAutoPerformanceTracing = false;
  // Privacidade: nada de dados pessoais, capturas de tela ou textos da tela
  // (a hierarquia de widgets já vem desligada por padrão).
  o.sendDefaultPii = false;
  o.attachScreenshot = false;
  o.enableUserInteractionBreadcrumbs = false;
  o.enablePrintBreadcrumbs = false;
  o.beforeSend = (event, hint) => scrubCrashEvent(event);
}

/// Erros do SQLite/Drift trazem os valores da consulta ("parameters: …"),
/// que podem ser nomes de hábitos ou anotações de humor. Corta essa parte.
@visibleForTesting
SentryEvent scrubCrashEvent(SentryEvent event) {
  for (final e in event.exceptions ?? const <SentryException>[]) {
    final value = e.value;
    if (value != null) e.value = scrubErrorText(value);
  }
  final message = event.message;
  if (message != null) {
    event.message = SentryMessage(
      scrubErrorText(message.formatted),
      template: message.template,
    );
  }
  return event;
}

final _sqlParameters = RegExp(
  r'parameters:.*',
  caseSensitive: false,
  dotAll: true,
);

@visibleForTesting
String scrubErrorText(String text) =>
    text.replaceAll(_sqlParameters, 'parameters: [removidos]');
