import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum PulseSnackKind { neutral, success, error }

/// Snackbar com contraste forte (legível sobre fundo escuro do app).
void showPulseSnackBar(
  BuildContext context,
  String message, {
  PulseSnackKind kind = PulseSnackKind.neutral,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();

  late final Color bg;
  late final Color fg;
  late final IconData icon;

  switch (kind) {
    case PulseSnackKind.success:
      bg = PulseColors.success;
      fg = PulseColors.background;
      icon = Icons.check_circle_outline_rounded;
      break;
    case PulseSnackKind.error:
      bg = PulseColors.snackErrorBg;
      fg = PulseColors.snackErrorFg;
      icon = Icons.error_outline_rounded;
      break;
    case PulseSnackKind.neutral:
      bg = PulseColors.snackNeutralBg;
      fg = PulseColors.snackNeutralFg;
      icon = Icons.info_outline_rounded;
      break;
  }

  final duration =
      kind == PulseSnackKind.error ? const Duration(seconds: 6) : const Duration(seconds: 4);

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: bg,
      duration: duration,
      margin: const EdgeInsets.all(14),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: fg.withValues(alpha: kind == PulseSnackKind.error ? 0.25 : 0.12),
        ),
      ),
      showCloseIcon: true,
      closeIconColor: fg.withValues(alpha: 0.9),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                message,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight:
                      kind == PulseSnackKind.error ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
