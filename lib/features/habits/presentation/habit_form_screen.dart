import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/presentation/widgets/glass_panel.dart';
import '../../../core/presentation/widgets/pulse_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../insights/presentation/insights_providers.dart';
import '../domain/habit_daily_goal_display.dart';
import '../domain/habit_reminder_times_codec.dart';
import '../domain/pulse_habit_icons.dart';
const List<int> _kAccentColors = [
  0xFF7C83FF,
  0xFF4ADE80,
  0xFFFBBF24,
  0xFFF472B6,
  0xFF38BDF8,
  0xFFFB7185,
];

const int _kMaxReminderSlots = 24;

/// Seg–Dom em [DateTime.weekday].
const List<int> _kWeekdays = [
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
];

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habit});

  final Habit? habit;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _target;
  late final TextEditingController _targetUnit;
  late final TextEditingController _spreadCount;

  late String _iconKey;
  late int _colorArgb;
  late Set<int> _weekdays;
  late List<TimeOfDay> _reminderTimes;
  bool _remindersOn = false;
  TimeOfDay _spreadStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _spreadEnd = const TimeOfDay(hour: 21, minute: 0);

  bool _saving = false;

  bool get _isEdit => widget.habit != null;

  void _onMetaChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _name = TextEditingController(text: h?.name ?? '');
    _description = TextEditingController(text: h?.description ?? '');
    _category = TextEditingController(text: h?.category ?? '');
    _target =
        TextEditingController(text: (h?.dailyTarget ?? 1).toString());
    _targetUnit = TextEditingController(text: h?.dailyTargetUnit ?? '');
    _spreadCount = TextEditingController(text: '3');
    _iconKey = h?.iconKey ?? 'task_alt';
    _colorArgb = h?.colorArgb ?? _kAccentColors.first;
    _weekdays =
        h == null ? _kWeekdays.toSet() : _decodeWeekdays(h.weekdaysBitmask);

    var times = decodeHabitReminderTimes(h?.reminderTimesJson);
    if (times.isEmpty && h != null) {
      final rh = h.reminderHour;
      final rm = h.reminderMinute;
      if (rh != null &&
          rm != null &&
          rh >= 0 &&
          rh < 24 &&
          rm >= 0 &&
          rm < 60) {
        times = [TimeOfDay(hour: rh, minute: rm)];
      }
    }
    _reminderTimes = times.isNotEmpty
        ? [...times]
        : [const TimeOfDay(hour: 9, minute: 0)];
    _remindersOn = times.isNotEmpty;
    _target.addListener(_onMetaChanged);
    _targetUnit.addListener(_onMetaChanged);
  }

  @override
  void dispose() {
    _target.removeListener(_onMetaChanged);
    _targetUnit.removeListener(_onMetaChanged);
    _name.dispose();
    _description.dispose();
    _category.dispose();
    _target.dispose();
    _targetUnit.dispose();
    _spreadCount.dispose();
    super.dispose();
  }

  static Set<int> _decodeWeekdays(int mask) {
    final set = <int>{};
    for (var i = 0; i < 7; i++) {
      if ((mask & (1 << i)) != 0) set.add(i + 1);
    }
    return set.isEmpty ? _kWeekdays.toSet() : set;
  }

  static int _encodeWeekdays(Set<int> days) {
    var m = 0;
    for (final d in days) {
      if (d >= 1 && d <= 7) m |= 1 << (d - 1);
    }
    return m == 0 ? 127 : m;
  }

  static List<TimeOfDay> _dedupeSorted(List<TimeOfDay> xs) {
    final map = <String, TimeOfDay>{};
    for (final t in xs) {
      map['${t.hour}:${t.minute}'] = t;
    }
    final out = map.values.toList();
    out.sort((a, b) {
      final c = a.hour.compareTo(b.hour);
      return c != 0 ? c : a.minute.compareTo(b.minute);
    });
    return out;
  }

  Future<void> _pickReminderAt(int index) async {
    final ctx = mounted ? context : null;
    if (ctx == null) return;
    final cur = _reminderTimes[index];
    final t = await showTimePicker(context: ctx, initialTime: cur);
    if (t != null && mounted) {
      setState(() => _reminderTimes[index] = t);
    }
  }

  Future<void> _addReminder() async {
    if (_reminderTimes.length >= _kMaxReminderSlots) {
      showPulseSnackBar(
        context,
        'No máximo $_kMaxReminderSlots lembretes por hábito.',
        kind: PulseSnackKind.error,
      );
      return;
    }
    final ctx = mounted ? context : null;
    if (ctx == null) return;
    final t = await showTimePicker(
      context: ctx,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (t != null && mounted) {
      setState(() => _reminderTimes.add(t));
    }
  }

  void _removeReminderAt(int i) {
    if (_reminderTimes.length <= 1) return;
    setState(() => _reminderTimes.removeAt(i));
  }

  void _applySpread() {
    final n = int.tryParse(_spreadCount.text.trim());
    if (n == null || n < 1) {
      showPulseSnackBar(
        context,
        'Informe quantos lembretes (número inteiro ≥ 1).',
        kind: PulseSnackKind.error,
      );
      return;
    }
    if (n > _kMaxReminderSlots) {
      showPulseSnackBar(
        context,
        'No máximo $_kMaxReminderSlots lembretes.',
        kind: PulseSnackKind.error,
      );
      return;
    }
    setState(() {
      _reminderTimes = _dedupeSorted(
        spreadRemindersBetween(
          count: n,
          start: _spreadStart,
          end: _spreadEnd,
        ),
      );
      _remindersOn = true;
    });
    showPulseSnackBar(
      context,
      'Horários atualizados — ajuste item a item se quiser.',
      kind: PulseSnackKind.neutral,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(authRepositoryProvider).currentUser?.id;
    if (uid == null) {
      if (mounted) {
        showPulseSnackBar(
          context,
          'Faça login para salvar hábitos.',
          kind: PulseSnackKind.error,
        );
      }
      return;
    }

    if (_remindersOn && _reminderTimes.isEmpty) {
      showPulseSnackBar(
        context,
        'Adicione pelo menos um horário de lembrete.',
        kind: PulseSnackKind.error,
      );
      return;
    }

    final name = _name.text.trim();
    final descText = _description.text.trim();
    final description = descText.isEmpty ? null : descText;
    final catText = _category.text.trim();
    final category = catText.isEmpty ? null : catText;
    final targetParsed = double.tryParse(_target.text.replaceAll(',', '.'));
    final dailyTarget =
        targetParsed != null && targetParsed > 0 ? targetParsed : 1.0;

    final unitText = _targetUnit.text.trim();
    final dailyTargetUnit = unitText.isEmpty ? null : unitText;

    final bitmask = _encodeWeekdays(_weekdays);
    String? reminderJson;
    if (_remindersOn) {
      final sorted = _dedupeSorted(_reminderTimes);
      if (sorted.isEmpty) {
        showPulseSnackBar(
          context,
          'Defina ao menos um horário de lembrete.',
          kind: PulseSnackKind.error,
        );
        return;
      }
      reminderJson = encodeHabitReminderTimes(sorted);
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(habitsRepositoryProvider);
      if (_isEdit) {
        await repo.updateHabitFull(
          habit: widget.habit!,
          name: name,
          description: description,
          category: category,
          iconKey: _iconKey,
          colorArgb: _colorArgb,
          weekdaysBitmask: bitmask,
          dailyTarget: dailyTarget,
          dailyTargetUnit: dailyTargetUnit,
          reminderTimesJson: reminderJson,
        );
      } else {
        await repo.createHabit(
          userId: uid,
          name: name,
          description: description,
          category: category,
          iconKey: _iconKey,
          colorArgb: _colorArgb,
          weekdaysBitmask: bitmask,
          dailyTarget: dailyTarget,
          dailyTargetUnit: dailyTargetUnit,
          reminderTimesJson: reminderJson,
        );
      }
      try {
        await ref.read(pulseHabitNotificationSchedulerProvider).rescheduleAll(uid);
        await ref.read(pulseSyncEngineProvider).flushOutbox(uid);
      } catch (_) {}
      ref.invalidate(dashboardSnapshotProvider);
      ref.invalidate(insightsListProvider);
      ref.invalidate(gamificationProfileProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          'Erro ao salvar: $e',
          kind: PulseSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final h = widget.habit;
    if (h == null) return;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir hábito?'),
            content: Text('«${h.name}» será removido da sua lista.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;
    try {
      await ref.read(habitsRepositoryProvider).deleteHabit(h);
      try {
        final u = ref.read(authRepositoryProvider).currentUser?.id;
        if (u != null) {
          await ref.read(pulseHabitNotificationSchedulerProvider).rescheduleAll(u);
          await ref.read(pulseSyncEngineProvider).flushOutbox(u);
        }
      } catch (_) {}
      ref.invalidate(dashboardSnapshotProvider);
      ref.invalidate(insightsListProvider);
      ref.invalidate(gamificationProfileProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showPulseSnackBar(
          context,
          'Erro ao excluir: $e',
          kind: PulseSnackKind.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_isEdit ? 'Editar hábito' : 'Novo hábito'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Excluir',
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex.: Água, Leitura, Caminhada…',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Categoria (opcional)',
                hintText: 'Ex.: Saúde',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Meta do dia',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'O valor é sempre numérico; a unidade explica o contexto '
              '(km, copos, minutos, páginas…).',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: PulseColors.textSecondary,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Valor numérico',
                hintText: 'Ex.: 5, 2.5, 20',
              ),
              validator: (v) {
                final t = (v ?? '').trim().replaceAll(',', '.');
                if (t.isEmpty) return 'Informe um valor maior que zero';
                final parsed = double.tryParse(t);
                if (parsed == null || parsed <= 0) {
                  return 'Use apenas números (ex.: 5 ou 2,5)';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _targetUnit,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'Unidade ou medida (opcional)',
                hintText: 'Ex.: km, copos, min, páginas',
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ex.: km, km/dia, copos, min, páginas, repetições',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: PulseColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatDailyGoalLine(
                double.tryParse(_target.text.replaceAll(',', '.')) ?? 1.0,
                _targetUnit.text.trim().isEmpty
                    ? null
                    : _targetUnit.text.trim(),
              ),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: PulseColors.accent.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: 22),
            Text(
              'Dias da semana',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final d in _kWeekdays)
                  FilterChip(
                    label: Text(_weekdayShort(d)),
                    selected: _weekdays.contains(d),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        _weekdays.add(d);
                      } else {
                        _weekdays.remove(d);
                      }
                      if (_weekdays.isEmpty) {
                        _weekdays = {d};
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Ícone',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final key in kPulseHabitIconKeys)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Icon(pulseHabitIcon(key), size: 22),
                        selected: _iconKey == key,
                        onSelected: (_) => setState(() => _iconKey = key),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Cor',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final argb in _kAccentColors)
                  GestureDetector(
                    onTap: () => setState(() => _colorArgb = argb),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(argb),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorArgb == argb
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: _colorArgb == argb
                            ? [
                                BoxShadow(
                                  color: Color(argb).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Lembretes no dia',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vários horários no mesmo dia — ideal para hábitos que se repetem.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: PulseColors.textSecondary,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativar lembretes neste hábito'),
              value: _remindersOn,
              onChanged: (v) {
                setState(() {
                  _remindersOn = v;
                  if (v && _reminderTimes.isEmpty) {
                    _reminderTimes = [const TimeOfDay(hour: 9, minute: 0)];
                  }
                });
              },
            ),
            if (_remindersOn) ...[
              for (var i = 0; i < _reminderTimes.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor:
                        PulseColors.accent.withValues(alpha: .2),
                    child: Text('${i + 1}',
                        style:
                            const TextStyle(color: PulseColors.accent, fontSize: 13)),
                  ),
                  title: Text(_reminderTimes[i].format(context)),
                  trailing: IconButton(
                    tooltip: 'Remover',
                    onPressed: () => _removeReminderAt(i),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  onTap: () => _pickReminderAt(i),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addReminder,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar horário'),
                ),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Gerar vários lembretes no intervalo',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                childrenPadding: const EdgeInsets.only(bottom: 12),
                children: [
                  TextField(
                    controller: _spreadCount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Quantos lembretes',
                      helperText:
                          'Ex.: copos de água = 8 distribui vários pings no dia.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Entre ${_spreadStart.format(context)}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final t =
                            await showTimePicker(context: context, initialTime: _spreadStart);
                        if (t != null) setState(() => _spreadStart = t);
                      },
                      child: const Text('Início'),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('E ${_spreadEnd.format(context)}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final t =
                            await showTimePicker(context: context, initialTime: _spreadEnd);
                        if (t != null) setState(() => _spreadEnd = t);
                      },
                      child: const Text('Fim'),
                    ),
                  ),
                  FilledButton(
                    onPressed: _applySpread,
                    child: const Text('Preencher lista de horários'),
                  ),
                ],
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassPanel(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEdit ? 'Salvar alterações' : 'Criar hábito'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekdayShort(int weekday) {
    const abbrev = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return abbrev[weekday - 1];
  }
}
