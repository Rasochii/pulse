import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/achievement_defs.dart';
import 'gamification_providers.dart';

enum AchievementFilter { all, unlocked, locked }

/// Catálogo completo de conquistas com filtro conquistadas e pendentes.
class AchievementsCatalogScreen extends ConsumerStatefulWidget {
  const AchievementsCatalogScreen({super.key});

  @override
  ConsumerState<AchievementsCatalogScreen> createState() =>
      _AchievementsCatalogScreenState();
}

class _AchievementsCatalogScreenState
    extends ConsumerState<AchievementsCatalogScreen> {
  AchievementFilter _filter = AchievementFilter.all;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(unlockedAchievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conquistas'),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PulseColors.accent),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erro: $e'),
          ),
        ),
        data: (unlocks) {
          final unlockedKeys = unlocks.map((u) => u.achievementKey).toSet();
          final filtered = kAchievementCatalog.where((def) {
            final has = unlockedKeys.contains(def.key);
            switch (_filter) {
              case AchievementFilter.all:
                return true;
              case AchievementFilter.unlocked:
                return has;
              case AchievementFilter.locked:
                return !has;
            }
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _filter == AchievementFilter.all,
                      selectedColor:
                          PulseColors.accent.withValues(alpha: 0.35),
                      onSelected: (_) {
                        setState(() => _filter = AchievementFilter.all);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Conquistadas'),
                      selected: _filter == AchievementFilter.unlocked,
                      selectedColor:
                          PulseColors.accent.withValues(alpha: 0.35),
                      onSelected: (_) {
                        setState(() => _filter = AchievementFilter.unlocked);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Pendentes'),
                      selected: _filter == AchievementFilter.locked,
                      selectedColor:
                          PulseColors.accent.withValues(alpha: 0.35),
                      onSelected: (_) {
                        setState(() => _filter = AchievementFilter.locked);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${unlockedKeys.length}/${kAchievementCatalog.length} desbloqueadas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: PulseColors.accent,
                  onRefresh: () async {
                    ref.invalidate(unlockedAchievementsProvider);
                    await ref.read(unlockedAchievementsProvider.future);
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 48),
                            Center(
                              child: Text(
                                _filter == AchievementFilter.unlocked
                                    ? 'Você ainda não tem conquistas nesta lista.'
                                    : _filter == AchievementFilter.locked
                                        ? 'Tudo desbloqueado. Mandou bem!'
                                        : 'Sem itens aqui.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final def = filtered[index];
                            final has = unlockedKeys.contains(def.key);
                            return Card(
                              elevation: 0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.65),
                              child: ListTile(
                                leading: Icon(
                                  has
                                      ? Icons.workspace_premium_rounded
                                      : Icons.lock_outline_rounded,
                                  color: has
                                      ? PulseColors.success
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                title: Text(def.title),
                                subtitle: Text(def.description),
                                trailing: has
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: PulseColors.success,
                                        size: 22,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
