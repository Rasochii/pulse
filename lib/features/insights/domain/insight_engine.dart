import '../../../core/utils/date_key.dart';
import '../../../core/database/app_database.dart';

class InsightVm {
  const InsightVm({
    required this.title,
    required this.detail,
    required this.sentimentBias,
  });

  final String title;
  final String detail;
  final double sentimentBias; // −1 pessimista … +1 otimista
}

/// Motor heurístico local — Plano 5 (templates).
abstract final class InsightEngine {
  static List<InsightVm> generate({
    required List<Habit> habits,
    required List<HabitCompletion> completions,
    required DateTime now,
    List<int>? moodsLast7d,
  }) {
    if (habits.isEmpty) {
      return const [
        InsightVm(
          title: 'Por onde começo?',
          detail:
              'Crie seu primeiro hábito curto para tirar atrito no dia a dia. Pequenas repetições vencem grandes promessas espaçadas.',
          sentimentBias: 0.35,
        ),
      ];
    }

    final out = <InsightVm>[];
    final today = DateTime(now.year, now.month, now.day);
    final byHour = List<int>.filled(24, 0);
    var total30 = 0;
    final start30 = today.subtract(const Duration(days: 29));
    for (final c in completions) {
      if (c.dateKey < dateKeyFromDateTime(start30)) continue;
      total30++;
      final dt =
          DateTime.fromMillisecondsSinceEpoch(c.completedAtMs, isUtc: false);
      if (dt.hour >= 0 && dt.hour < 24) byHour[dt.hour]++;
    }

    var bestH = 0;
    var bestC = -1;
    for (var h = 0; h < 24; h++) {
      if (byHour[h] > bestC) {
        bestC = byHour[h];
        bestH = h;
      }
    }
    if (bestC > 0 && total30 >= 5) {
      out.add(
        InsightVm(
          title: 'Ritmo do dia',
          detail:
              'Suas marcações recentes costumam se concentrar por volta das $bestH h. '
              'Use esse horário para encaixar hábitos que pedem mais foco.',
          sentimentBias: 0.4,
        ),
      );
    }

    final dowHits = List<int>.filled(7, 0);
    final dowTotal = List<int>.filled(7, 0);
    for (var d = 0; d < 30; d++) {
      final day = start30.add(Duration(days: d));
      final w = day.weekday - 1;
      var exp = 0;
      for (final h in habits) {
        if (isWeekdayInBitmask(day.weekday, h.weekdaysBitmask)) exp++;
      }
      if (exp == 0) continue;
      dowTotal[w] += exp;
      final set = <String>{};
      for (final c in completions) {
        if (c.dateKey == dateKeyFromDateTime(day)) set.add(c.habitId);
      }
      dowHits[w] += set.length;
    }
    var bestD = 0;
    var worstD = 0;
    var bestR = -1.0;
    var worstR = 2.0;
    for (var i = 0; i < 7; i++) {
      if (dowTotal[i] == 0) continue;
      final r = dowHits[i] / dowTotal[i];
      if (r > bestR) {
        bestR = r;
        bestD = i;
      }
      if (r < worstR) {
        worstR = r;
        worstD = i;
      }
    }
    const dowPrep = [
      'nas segundas-feiras',
      'nas terças-feiras',
      'nas quartas-feiras',
      'nas quintas-feiras',
      'nas sextas-feiras',
      'nos sábados',
      'nos domingos',
    ];
    if (bestR > 0.35 && worstR < 0.95 && bestD != worstD && dowTotal[worstD] > 0) {
      out.add(
        InsightVm(
          title: 'Mapa da semana',
          detail:
              'Seu índice costuma ser melhor ${dowPrep[bestD]} e mais fraco ${dowPrep[worstD]}. '
              'Que tal reduzir a carga no dia mais difícil ou revisar hábitos na véspera?',
          sentimentBias: 0.1,
        ),
      );
    }

    if (moodsLast7d != null && moodsLast7d.length >= 3) {
      final avg = moodsLast7d.reduce((a, b) => a + b) / moodsLast7d.length;
      if (avg >= 4) {
        out.add(
          InsightVm(
            title: 'Energia alta',
            detail:
                'Seus check-ins de humor recentes estão bons. '
                'É um bom momento para encaixar hábitos que você vinha empurrando com a barriga.',
            sentimentBias: 0.55,
          ),
        );
      } else if (avg <= 2) {
        out.add(
          InsightVm(
            title: 'Fase leve',
            detail:
                'Quando o humor anda baixo, combinam metas bem menores por alguns dias. '
                'Fechar um único hábito já conta como vitória.',
            sentimentBias: -0.2,
          ),
        );
      }
    }

    if (out.isEmpty) {
      out.add(
        InsightVm(
          title: 'Continuidade',
          detail:
              'Continue registrando — com o tempo aparecem padrões melhores para personalizar as dicas.',
          sentimentBias: 0.2,
        ),
      );
    }
    return out.take(6).toList();
  }
}
