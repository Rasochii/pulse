import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../insights/presentation/insights_providers.dart';
import 'wellbeing_providers.dart';
import 'wellbeing_summary_provider.dart';

Future<void> showWellbeingQuickSheet(BuildContext context, WidgetRef ref) async {
  final uid = ref.read(authRepositoryProvider).currentUser?.id;
  if (uid == null || uid.isEmpty) {
    showPulseSnackBar(
      context,
      'Faça login para registrar seu humor.',
      kind: PulseSnackKind.error,
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _WellbeingBody(userId: uid),
  );
}

class _WellbeingBody extends ConsumerStatefulWidget {
  const _WellbeingBody({required this.userId});

  final String userId;

  @override
  ConsumerState<_WellbeingBody> createState() => _WellbeingBodyState();
}

class _WellbeingBodyState extends ConsumerState<_WellbeingBody> {
  double _mood = 3;
  double _energy = 3;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GlassPanel(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Como você está?',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 14),
              Text('Humor (1–5)', style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: _mood,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_mood.round()}',
                activeColor: PulseColors.accent,
                onChanged: (v) => setState(() => _mood = v),
              ),
              Text(
                'Energia (1–5)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Slider(
                value: _energy,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_energy.round()}',
                activeColor: PulseColors.success,
                onChanged: (v) => setState(() => _energy = v),
              ),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Nota curta (opcional)',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () async {
                  try {
                    await ref.read(wellbeingRepositoryProvider).logCheckIn(
                          userId: widget.userId,
                          mood: _mood.round(),
                          energy: _energy.round(),
                          note: _note.text,
                          syncOutbox: ref.read(syncOutboxWriterProvider),
                        );
                    ref.invalidate(insightsListProvider);
                    ref.invalidate(wellbeingUiSummaryProvider);
                    if (context.mounted) Navigator.of(context).pop();
                  } catch (e) {
                    if (context.mounted) {
                      showPulseSnackBar(
                        context,
                        'Não foi possível salvar: $e',
                        kind: PulseSnackKind.error,
                      );
                    }
                  }
                },
                child: const Text('Salvar check-in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
