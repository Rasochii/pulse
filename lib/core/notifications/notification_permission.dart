import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

/// Lembretes agendados dependem de notificações locais do sistema; no navegador não existem.
const bool kRemindersSupported = !kIsWeb;

bool _isAllowed(PermissionStatus s) =>
    s == PermissionStatus.granted ||
    s == PermissionStatus.provisional ||
    s == PermissionStatus.limited;

/// `true` se o sistema deixa o Pulse mostrar notificações.
Future<bool> pulseNotificationsAllowed() async {
  if (!kRemindersSupported) return true;
  try {
    return _isAllowed(await Permission.notification.status);
  } catch (_) {
    // Plataforma sem o plugin: não há o que bloquear.
    return true;
  }
}

/// Abre a tela de notificações do Pulse nos ajustes do aparelho (Android 8+);
/// nos demais casos, a tela de ajustes do app.
Future<void> openPulseNotificationSettings() async {
  if (!kRemindersSupported) return;
  try {
    final opened = await const MethodChannel('pulse/settings')
        .invokeMethod<bool>('openNotificationSettings');
    if (opened == true) return;
  } catch (_) {
    // iOS e versões antigas do Android: sem o canal, cai nos ajustes do app.
  }
  await openAppSettings();
}

/// Pede a permissão; se o sistema não mostrar mais o pedido, abre os ajustes
/// de notificação do Pulse.
Future<bool> enablePulseNotifications() async {
  if (!kRemindersSupported) return true;
  try {
    if (_isAllowed(await Permission.notification.request())) return true;
    await openPulseNotificationSettings();
    return false;
  } catch (_) {
    return true;
  }
}

/// Reconstrói com o estado da permissão; reavalia ao voltar para o app
/// (o usuário pode ter mudado nos ajustes do sistema).
class NotificationPermissionBuilder extends StatefulWidget {
  const NotificationPermissionBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    bool allowed,
    Future<void> Function() enable,
  ) builder;

  @override
  State<NotificationPermissionBuilder> createState() =>
      _NotificationPermissionBuilderState();
}

class _NotificationPermissionBuilderState
    extends State<NotificationPermissionBuilder> with WidgetsBindingObserver {
  bool _allowed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final allowed = await pulseNotificationsAllowed();
    if (mounted && allowed != _allowed) setState(() => _allowed = allowed);
  }

  Future<void> _enable() async {
    await enablePulseNotifications();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _allowed, _enable);
}
