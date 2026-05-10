import 'dart:developer' as developer;

/// Fachada de analytics (Plano 9). No-op em produção até integrar Firebase etc.
abstract interface class AnalyticsGateway {
  void logEvent(String name, [Map<String, Object?> extras = const {}]);
}

final class NoOpAnalyticsGateway implements AnalyticsGateway {
  const NoOpAnalyticsGateway();

  @override
  void logEvent(String name, [Map<String, Object?> extras = const {}]) {}
}

final class DebugAnalyticsGateway implements AnalyticsGateway {
  const DebugAnalyticsGateway();

  @override
  void logEvent(String name, [Map<String, Object?> extras = const {}]) {
    developer.log('$name ${extras.isEmpty ? '' : extras}',
        name: 'PulseAnalytics');
  }
}
