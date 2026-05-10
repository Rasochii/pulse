const kAchFirstStep = 'first_step';
const kAchStreak7 = 'streak_master_7';
const kAchPerfectDay = 'perfect_day';
const kAchCompletions30 = 'collector_30';

const kAchCompletions10 = 'collector_10';
const kAchCompletions100 = 'collector_100';
const kAchCompletions250 = 'collector_250';

const kAchStreak3 = 'streak_beginner_3';
const kAchStreak14 = 'streak_master_14';
const kAchStreak30 = 'streak_master_30';

const kAchPerfectDays3 = 'perfect_total_3';
const kAchPerfectDays10 = 'perfect_total_10';

const kAchHabitsTwo = 'habits_duo';
const kAchHabitsFive = 'habits_focus_5';

const kAchEarlyBird = 'early_bird';
const kAchNightOwl = 'night_owl';

const kAchXp500 = 'xp_seeker_500';
const kAchXp2000 = 'xp_master_2000';

const kAchLevel5 = 'level_rising_5';
const kAchLevel10 = 'level_veteran_10';

const kAchBestStreakEver14 = 'best_streak_14';
const kAchBestStreakEver30 = 'best_streak_30';

class AchievementDef {
  const AchievementDef({
    required this.key,
    required this.title,
    required this.description,
  });

  final String key;
  final String title;
  final String description;
}

const List<AchievementDef> kAchievementCatalog = [
  AchievementDef(
    key: kAchFirstStep,
    title: 'Primeiro passo',
    description: 'Você registrou pela primeira vez a conclusão de um hábito.',
  ),
  AchievementDef(
    key: kAchStreak3,
    title: 'Pé no acelerador',
    description: 'Você ficou 3 dias seguidos marcando o mesmo hábito.',
  ),
  AchievementDef(
    key: kAchStreak7,
    title: 'Dentro do ritmo',
    description: 'Você manteve 7 dias seguidos marcando um mesmo hábito.',
  ),
  AchievementDef(
    key: kAchStreak14,
    title: 'Duas semanas pegando fogo',
    description: 'Você manteve 14 dias seguidos no mesmo hábito.',
  ),
  AchievementDef(
    key: kAchStreak30,
    title: 'Um mês inteiro',
    description: 'Você ficou um mês de ponta a ponta marcando um mesmo hábito.',
  ),
  AchievementDef(
    key: kAchBestStreakEver14,
    title: 'Sequência forte',
    description:
        'Um dos seus hábitos já passou de 14 dias na melhor série que você fez até agora.',
  ),
  AchievementDef(
    key: kAchBestStreakEver30,
    title: 'Série monumental',
    description:
        'A maior sequência registrada em um hábito chegou a 30 dias ou mais.',
  ),
  AchievementDef(
    key: kAchPerfectDay,
    title: 'Dia zerado',
    description: 'Você marcou todos os hábitos programados para aquele dia.',
  ),
  AchievementDef(
    key: kAchPerfectDays3,
    title: 'Três dias redondos',
    description: 'Você marcou todos os hábitos em pelo menos três dias.',
  ),
  AchievementDef(
    key: kAchPerfectDays10,
    title: 'Dez dias impecáveis',
    description: 'Você somou dez dias com todos os hábitos marcados.',
  ),
  AchievementDef(
    key: kAchCompletions10,
    title: 'Dez marcações na conta',
    description: 'Foram registradas pelo menos dez marcas de conclusão de hábito.',
  ),
  AchievementDef(
    key: kAchCompletions30,
    title: 'Ritmo pegando',
    description: 'Você passou das 30 marcações cumulativas ao longo do tempo.',
  ),
  AchievementDef(
    key: kAchCompletions100,
    title: 'Marcador nato',
    description: 'Mais de 100 registros cumulativos nos seus hábitos.',
  ),
  AchievementDef(
    key: kAchCompletions250,
    title: 'Marcação em massa',
    description: 'Mais de 250 conclusões registradas até aqui.',
  ),
  AchievementDef(
    key: kAchHabitsTwo,
    title: 'Pé em dois projetos',
    description: 'Você já tem dois hábitos ativos criados.',
  ),
  AchievementDef(
    key: kAchHabitsFive,
    title: 'Cinco na rotina',
    description: 'Você chegou a cinco hábitos ativos ao mesmo tempo.',
  ),
  AchievementDef(
    key: kAchEarlyBird,
    title: 'Madrugador',
    description: 'Pelo menos uma marcação antes das oito da manhã.',
  ),
  AchievementDef(
    key: kAchNightOwl,
    title: 'Coruja de plantão',
    description: 'Pelo menos uma marcação entre às dez da noite e a meia-noite.',
  ),
  AchievementDef(
    key: kAchXp500,
    title: 'XP na veia',
    description: 'Você ultrapassou 500 pontos de experiência no total.',
  ),
  AchievementDef(
    key: kAchXp2000,
    title: 'Mão cheia de XP',
    description: 'Mais de 2.000 pontos de experiência acumulados.',
  ),
  AchievementDef(
    key: kAchLevel5,
    title: 'Subindo o degrau',
    description: 'Você alcançou o nível 5.',
  ),
  AchievementDef(
    key: kAchLevel10,
    title: 'Patamar de elite',
    description: 'Você chegou ao nível 10.',
  ),
];

AchievementDef? achievementByKey(String key) {
  for (final d in kAchievementCatalog) {
    if (d.key == key) return d;
  }
  return null;
}
