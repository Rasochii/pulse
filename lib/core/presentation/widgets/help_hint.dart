import 'package:flutter/material.dart';

import '../help_texts.dart';

/// Ícone "?" que abre uma folha curta explicando um termo da tela.
class HelpHint extends StatelessWidget {
  const HelpHint(this.help, {super.key});

  final HelpText help;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ajuda: ${help.title}',
      onPressed: () => showHelpSheet(context, help),
      icon: const Icon(Icons.help_outline_rounded),
      iconSize: 18,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Título de seção seguido do ícone de ajuda.
class TitleWithHelp extends StatelessWidget {
  const TitleWithHelp(this.text, {super.key, required this.help, this.style});

  final String text;
  final HelpText help;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: Text(text, style: style)),
        const SizedBox(width: 2),
        HelpHint(help),
      ],
    );
  }
}

Future<void> showHelpSheet(BuildContext context, HelpText help) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(help.title, style: text.titleLarge),
              const SizedBox(height: 12),
              Text(
                help.message,
                style: text.bodyMedium!.copyWith(height: 1.45),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendi'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
