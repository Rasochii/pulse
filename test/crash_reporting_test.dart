import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/monitoring/crash_reporting.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('remove os valores da consulta dos erros do banco', () {
    const raw =
        'SqliteException(19): UNIQUE constraint failed\n'
        '  Causing statement: INSERT INTO wellbeing (note) VALUES (?), '
        'parameters: Dia difícil no trabalho';
    expect(
      scrubErrorText(raw),
      'SqliteException(19): UNIQUE constraint failed\n'
      '  Causing statement: INSERT INTO wellbeing (note) VALUES (?), '
      'parameters: [removidos]',
    );
    expect(scrubErrorText('Null check operator'), 'Null check operator');
  });

  test('o filtro age nas exceções e na mensagem do evento', () {
    final event = SentryEvent(
      exceptions: [
        SentryException(type: 'SqliteException', value: 'x, parameters: Ler'),
      ],
      message: SentryMessage('falhou, parameters: Água'),
    );
    final out = scrubCrashEvent(event);
    expect(out.exceptions!.single.value, 'x, parameters: [removidos]');
    expect(out.message!.formatted, 'falhou, parameters: [removidos]');
  });

  test('desligado fora do release ou sem DSN', () {
    expect(crashReportingEnabled, isFalse);
  });
}
