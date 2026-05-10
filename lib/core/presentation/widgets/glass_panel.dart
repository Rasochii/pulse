import 'dart:ui';

import 'package:flutter/material.dart';

/// Painel com blur leve e borda sutil (glassmorphism discreto).
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillAlpha = isDark ? 0.45 : 0.72;
    final borderAlpha = isDark ? 0.55 : 0.4;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: fillAlpha),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: cs.outline.withValues(alpha: borderAlpha),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
