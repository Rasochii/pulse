/// Título e texto de uma explicação aberta pelo ícone "?".
class HelpText {
  const HelpText(this.title, this.message);

  final String title;
  final String message;
}

/// Textos de ajuda das telas, num só lugar para facilitar a revisão.
abstract final class HelpTexts {
  static const xp = HelpText(
    'Nível e XP',
    'Você ganha XP ao concluir hábitos, uma vez por hábito em cada dia:\n'
        '• 15 XP por hábito concluído;\n'
        '• +5 no primeiro hábito do dia;\n'
        '• +2 por dia de série do hábito, até +28;\n'
        '• +12 ao concluir todos os hábitos do dia.\n\n'
        'Cada nível pede 100 XP a mais que o anterior: 100 XP para chegar ao '
        'nível 2, mais 200 para o 3, e assim por diante.',
  );

  static const summary = HelpText(
    'Resumo',
    '• Hoje: a porcentagem dos hábitos agendados para hoje que você já '
        'concluiu.\n'
        '• Dias ideais: dias seguidos em que você concluiu todos os hábitos '
        'agendados. Dias sem hábito agendado não contam nem quebram a '
        'sequência, e hoje só entra quando estiver completo.\n'
        '• Soma 7 d: quantos hábitos você concluiu nos últimos 7 dias, '
        'contando hoje.',
  );

  static const checklist = HelpText(
    'Checklist',
    'Toque no quadrado à esquerda para marcar um hábito como feito. Nos '
        'hábitos com meta numérica, como 8 copos de água, o toque abre o '
        'contador.\n\n'
        '• Série: quantos dias agendados seguidos você concluiu o hábito. '
        'Enquanto hoje estiver pendente, a série não quebra.\n'
        '• Taxa 30 d: em quantos dos dias agendados dos últimos 30 você '
        'concluiu o hábito.\n\n'
        'Esqueceu de marcar? Escolha o dia acima da lista para corrigir até '
        '6 dias atrás.',
  );

  static const last7Days = HelpText(
    'Últimos 7 dias',
    'Cada barra mostra quantos hábitos você concluiu naquele dia. A última '
        'barra é hoje.',
  );

  static const heatmap = HelpText(
    'Heatmap',
    'Cada quadrado é um dia, e cada linha é uma semana, de segunda a '
        'domingo. A linha de baixo é a semana atual.\n\n'
        '• Meta fechada (verde): concluiu todos os hábitos agendados.\n'
        '• Parcial (amarelo): concluiu parte deles. Hoje fica amarelo até '
        'você concluir todos.\n'
        '• Atrasado (vermelho): não concluiu nenhum.\n'
        '• Sem meta (cinza): nenhum hábito agendado, ou um dia que ainda '
        'não chegou.',
  );

  static const topConsistency = HelpText(
    'Top consistência',
    'Os hábitos que você mais cumpriu nos últimos 14 dias. A porcentagem '
        'conta só os dias em que o hábito estava agendado: 100% quer dizer '
        'que você não deixou de fazer nenhum.',
  );

  static const peakHours = HelpText(
    'Horários com mais registros',
    'As horas do dia em que você mais marcou hábitos nos últimos 30 dias. '
        'O número entre parênteses é quantas vezes. Costumam ser bons '
        'horários para encaixar um hábito novo.',
  );

  static const habitList = HelpText(
    'Sequência e taxa',
    '• Sequência: quantos dias agendados seguidos você concluiu o hábito. '
        'Enquanto hoje estiver pendente, ela não quebra.\n'
        '• Taxa 30 d: em quantos dos dias agendados dos últimos 30 você '
        'concluiu o hábito. Hábitos criados há menos de 30 dias contam só '
        'desde a criação.\n\n'
        'Toque em um hábito para editar o nome, a meta, os dias e os '
        'lembretes.',
  );

  static const mood = HelpText(
    'Humor e energia',
    'Em cada check-in você dá uma nota de 1 a 5 para o humor (como está se '
        'sentindo) e para a energia (sua disposição). 1 é muito baixo e 5 é '
        'muito bom. Dá para fazer mais de um check-in por dia.\n\n'
        '• Média 7 d: a média dos check-ins dos últimos 7 dias.\n'
        '• Quando houver pelo menos 2 dias de humor alto (4 ou 5) e 2 de '
        'humor baixo (1 ou 2) nas últimas 2 semanas, o Pulse compara como '
        'foram seus hábitos nesses dias.',
  );

  static const insights = HelpText(
    'Como os insights funcionam',
    'Os insights são calculados no seu aparelho, a partir dos seus '
        'registros dos últimos 30 dias:\n'
        '• o horário em que você mais marca hábitos;\n'
        '• os dias da semana em que você vai melhor e pior;\n'
        '• o seu humor, quando houver 3 ou mais check-ins nos últimos 7 '
        'dias.\n\n'
        'Quanto mais você registra, mais os insights combinam com a sua '
        'rotina.',
  );
}
