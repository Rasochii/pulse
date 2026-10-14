import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import 'app_update.dart';

/// Envolve o app: bloqueia abaixo da versão mínima e avisa quando há versão
/// recomendada. Confere ao abrir e ao voltar para o app (no máximo a cada 10 min).
class UpdateGate extends StatefulWidget {
  const UpdateGate({
    super.key,
    required this.child,
    this.checker = const AppUpdateChecker(),
  });

  final Widget child;
  final AppUpdateChecker checker;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> with WidgetsBindingObserver {
  static const _minInterval = Duration(minutes: 10);

  UpdateStatus _status = UpdateStatus.upToDate;
  DateTime? _lastCheck;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Bloqueado: confere sempre ao voltar (a pessoa pode ter acabado de atualizar).
    final last = _lastCheck;
    if (_status.level == UpdateLevel.required ||
        last == null ||
        DateTime.now().difference(last) >= _minInterval) {
      _check();
    }
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final status = await widget.checker.check();
      _lastCheck = DateTime.now();
      if (mounted) setState(() => _status = status);
    } catch (_) {
      // Falha na conferência nunca bloqueia o app.
    } finally {
      _checking = false;
    }
  }

  Future<void> _openStore() async {
    final url = _status.storeUrl;
    if (url == null) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _dismiss() async {
    final build = _status.recommendedBuild;
    setState(() => _status = UpdateStatus.upToDate);
    await widget.checker.dismissRecommended(build);
  }

  @override
  Widget build(BuildContext context) {
    switch (_status.level) {
      case UpdateLevel.required:
        return _UpdateRequired(
          onUpdate: _status.storeUrl == null ? null : _openStore,
        );
      case UpdateLevel.recommended:
        return Stack(
          children: [
            widget.child,
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _UpdateBanner(onUpdate: _openStore, onDismiss: _dismiss),
            ),
          ],
        );
      case UpdateLevel.none:
        return widget.child;
    }
  }
}

class _UpdateRequired extends StatelessWidget {
  const _UpdateRequired({required this.onUpdate});

  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.system_update_rounded,
                size: 64,
                color: PulseColors.accent,
              ),
              const SizedBox(height: 24),
              Text(
                'Atualize o Pulse para continuar',
                textAlign: TextAlign.center,
                style: text.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Esta versão tem um problema que já foi corrigido. Atualize o app '
                'na loja; seus dados continuam guardados.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: onUpdate,
                style: FilledButton.styleFrom(
                  backgroundColor: PulseColors.accent,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Atualizar'),
              ),
              if (onUpdate == null) ...[
                const SizedBox(height: 12),
                Text(
                  'Procure "Pulse" na loja de apps do seu aparelho.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({required this.onUpdate, required this.onDismiss});

  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      minimum: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              const Icon(Icons.system_update_rounded, color: PulseColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nova versão do Pulse disponível.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(onPressed: onDismiss, child: const Text('Agora não')),
              FilledButton(onPressed: onUpdate, child: const Text('Atualizar')),
            ],
          ),
        ),
      ),
    );
  }
}
