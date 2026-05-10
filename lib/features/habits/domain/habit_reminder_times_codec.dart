import 'dart:convert';

import 'package:flutter/material.dart';

/// JSON: `[[9,0],[14,30],...]` (hora, minuto).
List<TimeOfDay> decodeHabitReminderTimes(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final out = <TimeOfDay>[];
    for (final e in decoded) {
      final pair = e as List<dynamic>;
      final h = pair[0] as int;
      final m = pair[1] as int;
      if (h >= 0 && h < 24 && m >= 0 && m < 60) {
        out.add(TimeOfDay(hour: h, minute: m));
      }
    }
    return out;
  } catch (_) {
    return [];
  }
}

String encodeHabitReminderTimes(List<TimeOfDay> times) {
  final sorted = [...times]..sort((a, b) {
      final c = a.hour.compareTo(b.hour);
      return c != 0 ? c : a.minute.compareTo(b.minute);
    });
  final pairs = sorted.map((t) => [t.hour, t.minute]).toList();
  return jsonEncode(pairs);
}

/// Distribui [count] horários entre [start] e [end] (inclusive).
List<TimeOfDay> spreadRemindersBetween({
  required int count,
  required TimeOfDay start,
  required TimeOfDay end,
}) {
  if (count < 1) return [];
  var a = start.hour * 60 + start.minute;
  var b = end.hour * 60 + end.minute;
  if (b < a) {
    final t = a;
    a = b;
    b = t;
  }
  final out = <TimeOfDay>[];
  for (var i = 0; i < count; i++) {
    final frac = count == 1 ? 0.5 : i / (count - 1);
    var m = (a + (b - a) * frac).round();
    if (m < a) m = a;
    if (m > b) m = b;
    out.add(TimeOfDay(hour: m ~/ 60, minute: m % 60));
  }
  return out;
}
