import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/theme/app_colors.dart';
import 'insights_providers.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insightsListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: PulseColors.accent),
          ),
          error: (e, _) =>
              Center(child: Text('Insights indisponíveis: $e')),
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text('Sem insights por enquanto.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              itemCount: list.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Insights',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  );
                }
                final vm = list[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vm.detail,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
