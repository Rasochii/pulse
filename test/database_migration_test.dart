import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/database/app_database.dart';

/// Banco como estava na versão 5 (antes da ordem manual), com dados de dois usuários.
NativeDatabase _v5Database() => NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
          CREATE TABLE habits (
            id TEXT NOT NULL PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT,
            icon_key TEXT NOT NULL DEFAULT 'task_alt',
            color_argb INTEGER NOT NULL DEFAULT 4286350335,
            weekdays_bitmask INTEGER NOT NULL DEFAULT 127,
            reminder_hour INTEGER,
            reminder_minute INTEGER,
            daily_target REAL NOT NULL DEFAULT 1.0,
            daily_target_unit TEXT,
            reminder_times_json TEXT,
            created_at_ms INTEGER NOT NULL,
            updated_at_ms INTEGER NOT NULL,
            deleted_at_ms INTEGER
          )
        ''');
        for (final (id, user, name) in [
          ('1', 'a', 'Ler'),
          ('2', 'a', 'Água'),
          ('3', 'a', 'Caminhar'),
          ('4', 'b', 'Meditar'),
          ('5', 'b', 'Alongar'),
        ]) {
          raw.execute(
            'INSERT INTO habits (id, user_id, name, created_at_ms, updated_at_ms) '
            'VALUES (?, ?, ?, 1, 1)',
            [id, user, name],
          );
        }
        raw.execute('PRAGMA user_version = 5');
      },
    );

void main() {
  test('v5 → v6: hábitos existentes mantêm a ordem alfabética de antes', () async {
    final db = PulseDatabase(_v5Database());
    addTearDown(db.close);

    final a = await db.habitsForUser('a');
    final b = await db.habitsForUser('b');

    // Ordem do SQLite (por código de caractere), a mesma usada antes da v6.
    expect(a.map((h) => h.name), ['Caminhar', 'Ler', 'Água']);
    expect(a.map((h) => h.sortOrder), [0, 1, 2]);
    // A numeração recomeça para cada usuário.
    expect(b.map((h) => h.name), ['Alongar', 'Meditar']);
    expect(b.map((h) => h.sortOrder), [0, 1]);

    // Hábito novo entra depois dos existentes.
    expect(await db.nextHabitSortOrder('a'), 3);
  });
}
