// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('task_alt'),
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF7C83FF),
  );
  static const VerificationMeta _weekdaysBitmaskMeta = const VerificationMeta(
    'weekdaysBitmask',
  );
  @override
  late final GeneratedColumn<int> weekdaysBitmask = GeneratedColumn<int>(
    'weekdays_bitmask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyTargetMeta = const VerificationMeta(
    'dailyTarget',
  );
  @override
  late final GeneratedColumn<double> dailyTarget = GeneratedColumn<double>(
    'daily_target',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _dailyTargetUnitMeta = const VerificationMeta(
    'dailyTargetUnit',
  );
  @override
  late final GeneratedColumn<String> dailyTargetUnit = GeneratedColumn<String>(
    'daily_target_unit',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 48,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderTimesJsonMeta = const VerificationMeta(
    'reminderTimesJson',
  );
  @override
  late final GeneratedColumn<String> reminderTimesJson =
      GeneratedColumn<String>(
        'reminder_times_json',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0,
          maxTextLength: 2000,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    description,
    category,
    iconKey,
    colorArgb,
    weekdaysBitmask,
    reminderHour,
    reminderMinute,
    dailyTarget,
    dailyTargetUnit,
    reminderTimesJson,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    }
    if (data.containsKey('weekdays_bitmask')) {
      context.handle(
        _weekdaysBitmaskMeta,
        weekdaysBitmask.isAcceptableOrUnknown(
          data['weekdays_bitmask']!,
          _weekdaysBitmaskMeta,
        ),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('daily_target')) {
      context.handle(
        _dailyTargetMeta,
        dailyTarget.isAcceptableOrUnknown(
          data['daily_target']!,
          _dailyTargetMeta,
        ),
      );
    }
    if (data.containsKey('daily_target_unit')) {
      context.handle(
        _dailyTargetUnitMeta,
        dailyTargetUnit.isAcceptableOrUnknown(
          data['daily_target_unit']!,
          _dailyTargetUnitMeta,
        ),
      );
    }
    if (data.containsKey('reminder_times_json')) {
      context.handle(
        _reminderTimesJsonMeta,
        reminderTimesJson.isAcceptableOrUnknown(
          data['reminder_times_json']!,
          _reminderTimesJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      weekdaysBitmask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_bitmask'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      ),
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      ),
      dailyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_target'],
      )!,
      dailyTargetUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_target_unit'],
      ),
      reminderTimesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_times_json'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? category;
  final String iconKey;
  final int colorArgb;

  /// Bits 0–6 = seg–dom (como [DateTime.weekday] − 1).
  final int weekdaysBitmask;
  final int? reminderHour;
  final int? reminderMinute;
  final double dailyTarget;
  final String? dailyTargetUnit;

  /// JSON `[[hora,minuto],...]` — vários lembretes por dia (ver também [reminderHour] legado).
  final String? reminderTimesJson;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.category,
    required this.iconKey,
    required this.colorArgb,
    required this.weekdaysBitmask,
    this.reminderHour,
    this.reminderMinute,
    required this.dailyTarget,
    this.dailyTargetUnit,
    this.reminderTimesJson,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['icon_key'] = Variable<String>(iconKey);
    map['color_argb'] = Variable<int>(colorArgb);
    map['weekdays_bitmask'] = Variable<int>(weekdaysBitmask);
    if (!nullToAbsent || reminderHour != null) {
      map['reminder_hour'] = Variable<int>(reminderHour);
    }
    if (!nullToAbsent || reminderMinute != null) {
      map['reminder_minute'] = Variable<int>(reminderMinute);
    }
    map['daily_target'] = Variable<double>(dailyTarget);
    if (!nullToAbsent || dailyTargetUnit != null) {
      map['daily_target_unit'] = Variable<String>(dailyTargetUnit);
    }
    if (!nullToAbsent || reminderTimesJson != null) {
      map['reminder_times_json'] = Variable<String>(reminderTimesJson);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      iconKey: Value(iconKey),
      colorArgb: Value(colorArgb),
      weekdaysBitmask: Value(weekdaysBitmask),
      reminderHour: reminderHour == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderHour),
      reminderMinute: reminderMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinute),
      dailyTarget: Value(dailyTarget),
      dailyTargetUnit: dailyTargetUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyTargetUnit),
      reminderTimesJson: reminderTimesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTimesJson),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      weekdaysBitmask: serializer.fromJson<int>(json['weekdaysBitmask']),
      reminderHour: serializer.fromJson<int?>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int?>(json['reminderMinute']),
      dailyTarget: serializer.fromJson<double>(json['dailyTarget']),
      dailyTargetUnit: serializer.fromJson<String?>(json['dailyTargetUnit']),
      reminderTimesJson: serializer.fromJson<String?>(
        json['reminderTimesJson'],
      ),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'weekdaysBitmask': serializer.toJson<int>(weekdaysBitmask),
      'reminderHour': serializer.toJson<int?>(reminderHour),
      'reminderMinute': serializer.toJson<int?>(reminderMinute),
      'dailyTarget': serializer.toJson<double>(dailyTarget),
      'dailyTargetUnit': serializer.toJson<String?>(dailyTargetUnit),
      'reminderTimesJson': serializer.toJson<String?>(reminderTimesJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? iconKey,
    int? colorArgb,
    int? weekdaysBitmask,
    Value<int?> reminderHour = const Value.absent(),
    Value<int?> reminderMinute = const Value.absent(),
    double? dailyTarget,
    Value<String?> dailyTargetUnit = const Value.absent(),
    Value<String?> reminderTimesJson = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => Habit(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    category: category.present ? category.value : this.category,
    iconKey: iconKey ?? this.iconKey,
    colorArgb: colorArgb ?? this.colorArgb,
    weekdaysBitmask: weekdaysBitmask ?? this.weekdaysBitmask,
    reminderHour: reminderHour.present ? reminderHour.value : this.reminderHour,
    reminderMinute: reminderMinute.present
        ? reminderMinute.value
        : this.reminderMinute,
    dailyTarget: dailyTarget ?? this.dailyTarget,
    dailyTargetUnit: dailyTargetUnit.present
        ? dailyTargetUnit.value
        : this.dailyTargetUnit,
    reminderTimesJson: reminderTimesJson.present
        ? reminderTimesJson.value
        : this.reminderTimesJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      weekdaysBitmask: data.weekdaysBitmask.present
          ? data.weekdaysBitmask.value
          : this.weekdaysBitmask,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      dailyTarget: data.dailyTarget.present
          ? data.dailyTarget.value
          : this.dailyTarget,
      dailyTargetUnit: data.dailyTargetUnit.present
          ? data.dailyTargetUnit.value
          : this.dailyTargetUnit,
      reminderTimesJson: data.reminderTimesJson.present
          ? data.reminderTimesJson.value
          : this.reminderTimesJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('weekdaysBitmask: $weekdaysBitmask, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('dailyTargetUnit: $dailyTargetUnit, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    description,
    category,
    iconKey,
    colorArgb,
    weekdaysBitmask,
    reminderHour,
    reminderMinute,
    dailyTarget,
    dailyTargetUnit,
    reminderTimesJson,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.category == this.category &&
          other.iconKey == this.iconKey &&
          other.colorArgb == this.colorArgb &&
          other.weekdaysBitmask == this.weekdaysBitmask &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.dailyTarget == this.dailyTarget &&
          other.dailyTargetUnit == this.dailyTargetUnit &&
          other.reminderTimesJson == this.reminderTimesJson &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> category;
  final Value<String> iconKey;
  final Value<int> colorArgb;
  final Value<int> weekdaysBitmask;
  final Value<int?> reminderHour;
  final Value<int?> reminderMinute;
  final Value<double> dailyTarget;
  final Value<String?> dailyTargetUnit;
  final Value<String?> reminderTimesJson;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.weekdaysBitmask = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.dailyTargetUnit = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.weekdaysBitmask = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.dailyTargetUnit = const Value.absent(),
    this.reminderTimesJson = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? iconKey,
    Expression<int>? colorArgb,
    Expression<int>? weekdaysBitmask,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<double>? dailyTarget,
    Expression<String>? dailyTargetUnit,
    Expression<String>? reminderTimesJson,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (weekdaysBitmask != null) 'weekdays_bitmask': weekdaysBitmask,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (dailyTarget != null) 'daily_target': dailyTarget,
      if (dailyTargetUnit != null) 'daily_target_unit': dailyTargetUnit,
      if (reminderTimesJson != null) 'reminder_times_json': reminderTimesJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? category,
    Value<String>? iconKey,
    Value<int>? colorArgb,
    Value<int>? weekdaysBitmask,
    Value<int?>? reminderHour,
    Value<int?>? reminderMinute,
    Value<double>? dailyTarget,
    Value<String?>? dailyTargetUnit,
    Value<String?>? reminderTimesJson,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      colorArgb: colorArgb ?? this.colorArgb,
      weekdaysBitmask: weekdaysBitmask ?? this.weekdaysBitmask,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      dailyTargetUnit: dailyTargetUnit ?? this.dailyTargetUnit,
      reminderTimesJson: reminderTimesJson ?? this.reminderTimesJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (weekdaysBitmask.present) {
      map['weekdays_bitmask'] = Variable<int>(weekdaysBitmask.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (dailyTarget.present) {
      map['daily_target'] = Variable<double>(dailyTarget.value);
    }
    if (dailyTargetUnit.present) {
      map['daily_target_unit'] = Variable<String>(dailyTargetUnit.value);
    }
    if (reminderTimesJson.present) {
      map['reminder_times_json'] = Variable<String>(reminderTimesJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('weekdaysBitmask: $weekdaysBitmask, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('dailyTargetUnit: $dailyTargetUnit, ')
          ..write('reminderTimesJson: $reminderTimesJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionsTable extends HabitCompletions
    with TableInfo<$HabitCompletionsTable, HabitCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<int> dateKey = GeneratedColumn<int>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta(
    'completedAtMs',
  );
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitId,
    dateKey,
    completedAtMs,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(
          data['completed_at_ms']!,
          _completedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMsMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, dateKey};
  @override
  HabitCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletion(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_key'],
      )!,
      completedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_ms'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $HabitCompletionsTable createAlias(String alias) {
    return $HabitCompletionsTable(attachedDatabase, alias);
  }
}

class HabitCompletion extends DataClass implements Insertable<HabitCompletion> {
  final String habitId;
  final int dateKey;
  final int completedAtMs;
  final double quantity;
  const HabitCompletion({
    required this.habitId,
    required this.dateKey,
    required this.completedAtMs,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['date_key'] = Variable<int>(dateKey);
    map['completed_at_ms'] = Variable<int>(completedAtMs);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  HabitCompletionsCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionsCompanion(
      habitId: Value(habitId),
      dateKey: Value(dateKey),
      completedAtMs: Value(completedAtMs),
      quantity: Value(quantity),
    );
  }

  factory HabitCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletion(
      habitId: serializer.fromJson<String>(json['habitId']),
      dateKey: serializer.fromJson<int>(json['dateKey']),
      completedAtMs: serializer.fromJson<int>(json['completedAtMs']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'dateKey': serializer.toJson<int>(dateKey),
      'completedAtMs': serializer.toJson<int>(completedAtMs),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  HabitCompletion copyWith({
    String? habitId,
    int? dateKey,
    int? completedAtMs,
    double? quantity,
  }) => HabitCompletion(
    habitId: habitId ?? this.habitId,
    dateKey: dateKey ?? this.dateKey,
    completedAtMs: completedAtMs ?? this.completedAtMs,
    quantity: quantity ?? this.quantity,
  );
  HabitCompletion copyWithCompanion(HabitCompletionsCompanion data) {
    return HabitCompletion(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      completedAtMs: data.completedAtMs.present
          ? data.completedAtMs.value
          : this.completedAtMs,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletion(')
          ..write('habitId: $habitId, ')
          ..write('dateKey: $dateKey, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, dateKey, completedAtMs, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletion &&
          other.habitId == this.habitId &&
          other.dateKey == this.dateKey &&
          other.completedAtMs == this.completedAtMs &&
          other.quantity == this.quantity);
}

class HabitCompletionsCompanion extends UpdateCompanion<HabitCompletion> {
  final Value<String> habitId;
  final Value<int> dateKey;
  final Value<int> completedAtMs;
  final Value<double> quantity;
  final Value<int> rowid;
  const HabitCompletionsCompanion({
    this.habitId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitCompletionsCompanion.insert({
    required String habitId,
    required int dateKey,
    required int completedAtMs,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       dateKey = Value(dateKey),
       completedAtMs = Value(completedAtMs);
  static Insertable<HabitCompletion> custom({
    Expression<String>? habitId,
    Expression<int>? dateKey,
    Expression<int>? completedAtMs,
    Expression<double>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (dateKey != null) 'date_key': dateKey,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitCompletionsCompanion copyWith({
    Value<String>? habitId,
    Value<int>? dateKey,
    Value<int>? completedAtMs,
    Value<double>? quantity,
    Value<int>? rowid,
  }) {
    return HabitCompletionsCompanion(
      habitId: habitId ?? this.habitId,
      dateKey: dateKey ?? this.dateKey,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<int>(dateKey.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('dateKey: $dateKey, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 2000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    op,
    payloadJson,
    createdAtMs,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String entity;
  final String op;
  final String payloadJson;
  final int createdAtMs;
  final int attempts;
  final String? lastError;
  const SyncOutboxData({
    required this.id,
    required this.entity,
    required this.op,
    required this.payloadJson,
    required this.createdAtMs,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['op'] = Variable<String>(op);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      entity: Value(entity),
      op: Value(op),
      payloadJson: Value(payloadJson),
      createdAtMs: Value(createdAtMs),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      op: serializer.fromJson<String>(json['op']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'op': serializer.toJson<String>(op),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? entity,
    String? op,
    String? payloadJson,
    int? createdAtMs,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxData(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    op: op ?? this.op,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      op: data.op.present ? data.op.value : this.op,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    op,
    payloadJson,
    createdAtMs,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.op == this.op &&
          other.payloadJson == this.payloadJson &&
          other.createdAtMs == this.createdAtMs &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> op;
  final Value<String> payloadJson;
  final Value<int> createdAtMs;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.op = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String entity,
    required String op,
    required String payloadJson,
    required int createdAtMs,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entity = Value(entity),
       op = Value(op),
       payloadJson = Value(payloadJson),
       createdAtMs = Value(createdAtMs);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? op,
    Expression<String>? payloadJson,
    Expression<int>? createdAtMs,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (op != null) 'op': op,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? op,
    Value<String>? payloadJson,
    Value<int>? createdAtMs,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('op: $op, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GamificationProfilesTable extends GamificationProfiles
    with TableInfo<$GamificationProfilesTable, GamificationProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamificationProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, totalXp, level, updatedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gamification_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<GamificationProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  GamificationProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GamificationProfile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $GamificationProfilesTable createAlias(String alias) {
    return $GamificationProfilesTable(attachedDatabase, alias);
  }
}

class GamificationProfile extends DataClass
    implements Insertable<GamificationProfile> {
  final String userId;
  final int totalXp;
  final int level;
  final int updatedAtMs;
  const GamificationProfile({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['total_xp'] = Variable<int>(totalXp);
    map['level'] = Variable<int>(level);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  GamificationProfilesCompanion toCompanion(bool nullToAbsent) {
    return GamificationProfilesCompanion(
      userId: Value(userId),
      totalXp: Value(totalXp),
      level: Value(level),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory GamificationProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GamificationProfile(
      userId: serializer.fromJson<String>(json['userId']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      level: serializer.fromJson<int>(json['level']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'totalXp': serializer.toJson<int>(totalXp),
      'level': serializer.toJson<int>(level),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  GamificationProfile copyWith({
    String? userId,
    int? totalXp,
    int? level,
    int? updatedAtMs,
  }) => GamificationProfile(
    userId: userId ?? this.userId,
    totalXp: totalXp ?? this.totalXp,
    level: level ?? this.level,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  GamificationProfile copyWithCompanion(GamificationProfilesCompanion data) {
    return GamificationProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      level: data.level.present ? data.level.value : this.level,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GamificationProfile(')
          ..write('userId: $userId, ')
          ..write('totalXp: $totalXp, ')
          ..write('level: $level, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, totalXp, level, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GamificationProfile &&
          other.userId == this.userId &&
          other.totalXp == this.totalXp &&
          other.level == this.level &&
          other.updatedAtMs == this.updatedAtMs);
}

class GamificationProfilesCompanion
    extends UpdateCompanion<GamificationProfile> {
  final Value<String> userId;
  final Value<int> totalXp;
  final Value<int> level;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const GamificationProfilesCompanion({
    this.userId = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.level = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamificationProfilesCompanion.insert({
    required String userId,
    this.totalXp = const Value.absent(),
    this.level = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<GamificationProfile> custom({
    Expression<String>? userId,
    Expression<int>? totalXp,
    Expression<int>? level,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (totalXp != null) 'total_xp': totalXp,
      if (level != null) 'level': level,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamificationProfilesCompanion copyWith({
    Value<String>? userId,
    Value<int>? totalXp,
    Value<int>? level,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return GamificationProfilesCompanion(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamificationProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('totalXp: $totalXp, ')
          ..write('level: $level, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserAchievementUnlocksTable extends UserAchievementUnlocks
    with TableInfo<$UserAchievementUnlocksTable, UserAchievementUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAchievementUnlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievementKeyMeta = const VerificationMeta(
    'achievementKey',
  );
  @override
  late final GeneratedColumn<String> achievementKey = GeneratedColumn<String>(
    'achievement_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMsMeta = const VerificationMeta(
    'unlockedAtMs',
  );
  @override
  late final GeneratedColumn<int> unlockedAtMs = GeneratedColumn<int>(
    'unlocked_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, achievementKey, unlockedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_achievement_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAchievementUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('achievement_key')) {
      context.handle(
        _achievementKeyMeta,
        achievementKey.isAcceptableOrUnknown(
          data['achievement_key']!,
          _achievementKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementKeyMeta);
    }
    if (data.containsKey('unlocked_at_ms')) {
      context.handle(
        _unlockedAtMsMeta,
        unlockedAtMs.isAcceptableOrUnknown(
          data['unlocked_at_ms']!,
          _unlockedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, achievementKey};
  @override
  UserAchievementUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAchievementUnlock(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      achievementKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_key'],
      )!,
      unlockedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at_ms'],
      )!,
    );
  }

  @override
  $UserAchievementUnlocksTable createAlias(String alias) {
    return $UserAchievementUnlocksTable(attachedDatabase, alias);
  }
}

class UserAchievementUnlock extends DataClass
    implements Insertable<UserAchievementUnlock> {
  final String userId;
  final String achievementKey;
  final int unlockedAtMs;
  const UserAchievementUnlock({
    required this.userId,
    required this.achievementKey,
    required this.unlockedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['achievement_key'] = Variable<String>(achievementKey);
    map['unlocked_at_ms'] = Variable<int>(unlockedAtMs);
    return map;
  }

  UserAchievementUnlocksCompanion toCompanion(bool nullToAbsent) {
    return UserAchievementUnlocksCompanion(
      userId: Value(userId),
      achievementKey: Value(achievementKey),
      unlockedAtMs: Value(unlockedAtMs),
    );
  }

  factory UserAchievementUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAchievementUnlock(
      userId: serializer.fromJson<String>(json['userId']),
      achievementKey: serializer.fromJson<String>(json['achievementKey']),
      unlockedAtMs: serializer.fromJson<int>(json['unlockedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'achievementKey': serializer.toJson<String>(achievementKey),
      'unlockedAtMs': serializer.toJson<int>(unlockedAtMs),
    };
  }

  UserAchievementUnlock copyWith({
    String? userId,
    String? achievementKey,
    int? unlockedAtMs,
  }) => UserAchievementUnlock(
    userId: userId ?? this.userId,
    achievementKey: achievementKey ?? this.achievementKey,
    unlockedAtMs: unlockedAtMs ?? this.unlockedAtMs,
  );
  UserAchievementUnlock copyWithCompanion(
    UserAchievementUnlocksCompanion data,
  ) {
    return UserAchievementUnlock(
      userId: data.userId.present ? data.userId.value : this.userId,
      achievementKey: data.achievementKey.present
          ? data.achievementKey.value
          : this.achievementKey,
      unlockedAtMs: data.unlockedAtMs.present
          ? data.unlockedAtMs.value
          : this.unlockedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementUnlock(')
          ..write('userId: $userId, ')
          ..write('achievementKey: $achievementKey, ')
          ..write('unlockedAtMs: $unlockedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, achievementKey, unlockedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAchievementUnlock &&
          other.userId == this.userId &&
          other.achievementKey == this.achievementKey &&
          other.unlockedAtMs == this.unlockedAtMs);
}

class UserAchievementUnlocksCompanion
    extends UpdateCompanion<UserAchievementUnlock> {
  final Value<String> userId;
  final Value<String> achievementKey;
  final Value<int> unlockedAtMs;
  final Value<int> rowid;
  const UserAchievementUnlocksCompanion({
    this.userId = const Value.absent(),
    this.achievementKey = const Value.absent(),
    this.unlockedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserAchievementUnlocksCompanion.insert({
    required String userId,
    required String achievementKey,
    required int unlockedAtMs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       achievementKey = Value(achievementKey),
       unlockedAtMs = Value(unlockedAtMs);
  static Insertable<UserAchievementUnlock> custom({
    Expression<String>? userId,
    Expression<String>? achievementKey,
    Expression<int>? unlockedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (achievementKey != null) 'achievement_key': achievementKey,
      if (unlockedAtMs != null) 'unlocked_at_ms': unlockedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserAchievementUnlocksCompanion copyWith({
    Value<String>? userId,
    Value<String>? achievementKey,
    Value<int>? unlockedAtMs,
    Value<int>? rowid,
  }) {
    return UserAchievementUnlocksCompanion(
      userId: userId ?? this.userId,
      achievementKey: achievementKey ?? this.achievementKey,
      unlockedAtMs: unlockedAtMs ?? this.unlockedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (achievementKey.present) {
      map['achievement_key'] = Variable<String>(achievementKey.value);
    }
    if (unlockedAtMs.present) {
      map['unlocked_at_ms'] = Variable<int>(unlockedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementUnlocksCompanion(')
          ..write('userId: $userId, ')
          ..write('achievementKey: $achievementKey, ')
          ..write('unlockedAtMs: $unlockedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellbeingLogsTable extends WellbeingLogs
    with TableInfo<$WellbeingLogsTable, WellbeingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellbeingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMsMeta = const VerificationMeta(
    'loggedAtMs',
  );
  @override
  late final GeneratedColumn<int> loggedAtMs = GeneratedColumn<int>(
    'logged_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    loggedAtMs,
    mood,
    energy,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellbeing_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WellbeingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('logged_at_ms')) {
      context.handle(
        _loggedAtMsMeta,
        loggedAtMs.isAcceptableOrUnknown(
          data['logged_at_ms']!,
          _loggedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMsMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WellbeingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WellbeingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      loggedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_at_ms'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WellbeingLogsTable createAlias(String alias) {
    return $WellbeingLogsTable(attachedDatabase, alias);
  }
}

class WellbeingLog extends DataClass implements Insertable<WellbeingLog> {
  final String id;
  final String userId;
  final int loggedAtMs;
  final int mood;
  final int energy;
  final String? note;
  const WellbeingLog({
    required this.id,
    required this.userId,
    required this.loggedAtMs,
    required this.mood,
    required this.energy,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['logged_at_ms'] = Variable<int>(loggedAtMs);
    map['mood'] = Variable<int>(mood);
    map['energy'] = Variable<int>(energy);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WellbeingLogsCompanion toCompanion(bool nullToAbsent) {
    return WellbeingLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      loggedAtMs: Value(loggedAtMs),
      mood: Value(mood),
      energy: Value(energy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WellbeingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WellbeingLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      loggedAtMs: serializer.fromJson<int>(json['loggedAtMs']),
      mood: serializer.fromJson<int>(json['mood']),
      energy: serializer.fromJson<int>(json['energy']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'loggedAtMs': serializer.toJson<int>(loggedAtMs),
      'mood': serializer.toJson<int>(mood),
      'energy': serializer.toJson<int>(energy),
      'note': serializer.toJson<String?>(note),
    };
  }

  WellbeingLog copyWith({
    String? id,
    String? userId,
    int? loggedAtMs,
    int? mood,
    int? energy,
    Value<String?> note = const Value.absent(),
  }) => WellbeingLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    loggedAtMs: loggedAtMs ?? this.loggedAtMs,
    mood: mood ?? this.mood,
    energy: energy ?? this.energy,
    note: note.present ? note.value : this.note,
  );
  WellbeingLog copyWithCompanion(WellbeingLogsCompanion data) {
    return WellbeingLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      loggedAtMs: data.loggedAtMs.present
          ? data.loggedAtMs.value
          : this.loggedAtMs,
      mood: data.mood.present ? data.mood.value : this.mood,
      energy: data.energy.present ? data.energy.value : this.energy,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WellbeingLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('loggedAtMs: $loggedAtMs, ')
          ..write('mood: $mood, ')
          ..write('energy: $energy, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, loggedAtMs, mood, energy, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WellbeingLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.loggedAtMs == this.loggedAtMs &&
          other.mood == this.mood &&
          other.energy == this.energy &&
          other.note == this.note);
}

class WellbeingLogsCompanion extends UpdateCompanion<WellbeingLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> loggedAtMs;
  final Value<int> mood;
  final Value<int> energy;
  final Value<String?> note;
  final Value<int> rowid;
  const WellbeingLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.loggedAtMs = const Value.absent(),
    this.mood = const Value.absent(),
    this.energy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellbeingLogsCompanion.insert({
    required String id,
    required String userId,
    required int loggedAtMs,
    required int mood,
    required int energy,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       loggedAtMs = Value(loggedAtMs),
       mood = Value(mood),
       energy = Value(energy);
  static Insertable<WellbeingLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? loggedAtMs,
    Expression<int>? mood,
    Expression<int>? energy,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (loggedAtMs != null) 'logged_at_ms': loggedAtMs,
      if (mood != null) 'mood': mood,
      if (energy != null) 'energy': energy,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellbeingLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? loggedAtMs,
    Value<int>? mood,
    Value<int>? energy,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WellbeingLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loggedAtMs: loggedAtMs ?? this.loggedAtMs,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (loggedAtMs.present) {
      map['logged_at_ms'] = Variable<int>(loggedAtMs.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellbeingLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('loggedAtMs: $loggedAtMs, ')
          ..write('mood: $mood, ')
          ..write('energy: $energy, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitXpClaimsTable extends HabitXpClaims
    with TableInfo<$HabitXpClaimsTable, HabitXpClaim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitXpClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<int> dateKey = GeneratedColumn<int>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimedAtMsMeta = const VerificationMeta(
    'claimedAtMs',
  );
  @override
  late final GeneratedColumn<int> claimedAtMs = GeneratedColumn<int>(
    'claimed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, habitId, dateKey, claimedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_xp_claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitXpClaim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('claimed_at_ms')) {
      context.handle(
        _claimedAtMsMeta,
        claimedAtMs.isAcceptableOrUnknown(
          data['claimed_at_ms']!,
          _claimedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_claimedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, habitId, dateKey};
  @override
  HabitXpClaim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitXpClaim(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_key'],
      )!,
      claimedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claimed_at_ms'],
      )!,
    );
  }

  @override
  $HabitXpClaimsTable createAlias(String alias) {
    return $HabitXpClaimsTable(attachedDatabase, alias);
  }
}

class HabitXpClaim extends DataClass implements Insertable<HabitXpClaim> {
  final String userId;
  final String habitId;
  final int dateKey;
  final int claimedAtMs;
  const HabitXpClaim({
    required this.userId,
    required this.habitId,
    required this.dateKey,
    required this.claimedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['habit_id'] = Variable<String>(habitId);
    map['date_key'] = Variable<int>(dateKey);
    map['claimed_at_ms'] = Variable<int>(claimedAtMs);
    return map;
  }

  HabitXpClaimsCompanion toCompanion(bool nullToAbsent) {
    return HabitXpClaimsCompanion(
      userId: Value(userId),
      habitId: Value(habitId),
      dateKey: Value(dateKey),
      claimedAtMs: Value(claimedAtMs),
    );
  }

  factory HabitXpClaim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitXpClaim(
      userId: serializer.fromJson<String>(json['userId']),
      habitId: serializer.fromJson<String>(json['habitId']),
      dateKey: serializer.fromJson<int>(json['dateKey']),
      claimedAtMs: serializer.fromJson<int>(json['claimedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'habitId': serializer.toJson<String>(habitId),
      'dateKey': serializer.toJson<int>(dateKey),
      'claimedAtMs': serializer.toJson<int>(claimedAtMs),
    };
  }

  HabitXpClaim copyWith({
    String? userId,
    String? habitId,
    int? dateKey,
    int? claimedAtMs,
  }) => HabitXpClaim(
    userId: userId ?? this.userId,
    habitId: habitId ?? this.habitId,
    dateKey: dateKey ?? this.dateKey,
    claimedAtMs: claimedAtMs ?? this.claimedAtMs,
  );
  HabitXpClaim copyWithCompanion(HabitXpClaimsCompanion data) {
    return HabitXpClaim(
      userId: data.userId.present ? data.userId.value : this.userId,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      claimedAtMs: data.claimedAtMs.present
          ? data.claimedAtMs.value
          : this.claimedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitXpClaim(')
          ..write('userId: $userId, ')
          ..write('habitId: $habitId, ')
          ..write('dateKey: $dateKey, ')
          ..write('claimedAtMs: $claimedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, habitId, dateKey, claimedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitXpClaim &&
          other.userId == this.userId &&
          other.habitId == this.habitId &&
          other.dateKey == this.dateKey &&
          other.claimedAtMs == this.claimedAtMs);
}

class HabitXpClaimsCompanion extends UpdateCompanion<HabitXpClaim> {
  final Value<String> userId;
  final Value<String> habitId;
  final Value<int> dateKey;
  final Value<int> claimedAtMs;
  final Value<int> rowid;
  const HabitXpClaimsCompanion({
    this.userId = const Value.absent(),
    this.habitId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.claimedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitXpClaimsCompanion.insert({
    required String userId,
    required String habitId,
    required int dateKey,
    required int claimedAtMs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       habitId = Value(habitId),
       dateKey = Value(dateKey),
       claimedAtMs = Value(claimedAtMs);
  static Insertable<HabitXpClaim> custom({
    Expression<String>? userId,
    Expression<String>? habitId,
    Expression<int>? dateKey,
    Expression<int>? claimedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (habitId != null) 'habit_id': habitId,
      if (dateKey != null) 'date_key': dateKey,
      if (claimedAtMs != null) 'claimed_at_ms': claimedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitXpClaimsCompanion copyWith({
    Value<String>? userId,
    Value<String>? habitId,
    Value<int>? dateKey,
    Value<int>? claimedAtMs,
    Value<int>? rowid,
  }) {
    return HabitXpClaimsCompanion(
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      dateKey: dateKey ?? this.dateKey,
      claimedAtMs: claimedAtMs ?? this.claimedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<int>(dateKey.value);
    }
    if (claimedAtMs.present) {
      map['claimed_at_ms'] = Variable<int>(claimedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitXpClaimsCompanion(')
          ..write('userId: $userId, ')
          ..write('habitId: $habitId, ')
          ..write('dateKey: $dateKey, ')
          ..write('claimedAtMs: $claimedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PulseDatabase extends GeneratedDatabase {
  _$PulseDatabase(QueryExecutor e) : super(e);
  $PulseDatabaseManager get managers => $PulseDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(
    this,
  );
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $GamificationProfilesTable gamificationProfiles =
      $GamificationProfilesTable(this);
  late final $UserAchievementUnlocksTable userAchievementUnlocks =
      $UserAchievementUnlocksTable(this);
  late final $WellbeingLogsTable wellbeingLogs = $WellbeingLogsTable(this);
  late final $HabitXpClaimsTable habitXpClaims = $HabitXpClaimsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    habitCompletions,
    syncOutbox,
    gamificationProfiles,
    userAchievementUnlocks,
    wellbeingLogs,
    habitXpClaims,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_completions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_xp_claims', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> description,
      Value<String?> category,
      Value<String> iconKey,
      Value<int> colorArgb,
      Value<int> weekdaysBitmask,
      Value<int?> reminderHour,
      Value<int?> reminderMinute,
      Value<double> dailyTarget,
      Value<String?> dailyTargetUnit,
      Value<String?> reminderTimesJson,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> description,
      Value<String?> category,
      Value<String> iconKey,
      Value<int> colorArgb,
      Value<int> weekdaysBitmask,
      Value<int?> reminderHour,
      Value<int?> reminderMinute,
      Value<double> dailyTarget,
      Value<String?> dailyTargetUnit,
      Value<String?> reminderTimesJson,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$PulseDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitCompletionsTable, List<HabitCompletion>>
  _habitCompletionsRefsTable(_$PulseDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.habitCompletions,
        aliasName: $_aliasNameGenerator(
          db.habits.id,
          db.habitCompletions.habitId,
        ),
      );

  $$HabitCompletionsTableProcessedTableManager get habitCompletionsRefs {
    final manager = $$HabitCompletionsTableTableManager(
      $_db,
      $_db.habitCompletions,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _habitCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitXpClaimsTable, List<HabitXpClaim>>
  _habitXpClaimsRefsTable(_$PulseDatabase db) => MultiTypedResultKey.fromTable(
    db.habitXpClaims,
    aliasName: $_aliasNameGenerator(db.habits.id, db.habitXpClaims.habitId),
  );

  $$HabitXpClaimsTableProcessedTableManager get habitXpClaimsRefs {
    final manager = $$HabitXpClaimsTableTableManager(
      $_db,
      $_db.habitXpClaims,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitXpClaimsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$PulseDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdaysBitmask => $composableBuilder(
    column: $table.weekdaysBitmask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyTargetUnit => $composableBuilder(
    column: $table.dailyTargetUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTimesJson => $composableBuilder(
    column: $table.reminderTimesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitCompletionsRefs(
    Expression<bool> Function($$HabitCompletionsTableFilterComposer f) f,
  ) {
    final $$HabitCompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitCompletions,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitCompletionsTableFilterComposer(
            $db: $db,
            $table: $db.habitCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitXpClaimsRefs(
    Expression<bool> Function($$HabitXpClaimsTableFilterComposer f) f,
  ) {
    final $$HabitXpClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitXpClaims,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitXpClaimsTableFilterComposer(
            $db: $db,
            $table: $db.habitXpClaims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$PulseDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysBitmask => $composableBuilder(
    column: $table.weekdaysBitmask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyTargetUnit => $composableBuilder(
    column: $table.dailyTargetUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTimesJson => $composableBuilder(
    column: $table.reminderTimesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$PulseDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<int> get weekdaysBitmask => $composableBuilder(
    column: $table.weekdaysBitmask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyTargetUnit => $composableBuilder(
    column: $table.dailyTargetUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTimesJson => $composableBuilder(
    column: $table.reminderTimesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  Expression<T> habitCompletionsRefs<T extends Object>(
    Expression<T> Function($$HabitCompletionsTableAnnotationComposer a) f,
  ) {
    final $$HabitCompletionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitCompletions,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitCompletionsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitXpClaimsRefs<T extends Object>(
    Expression<T> Function($$HabitXpClaimsTableAnnotationComposer a) f,
  ) {
    final $$HabitXpClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitXpClaims,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitXpClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitXpClaims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({
            bool habitCompletionsRefs,
            bool habitXpClaimsRefs,
          })
        > {
  $$HabitsTableTableManager(_$PulseDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<int> weekdaysBitmask = const Value.absent(),
                Value<int?> reminderHour = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<double> dailyTarget = const Value.absent(),
                Value<String?> dailyTargetUnit = const Value.absent(),
                Value<String?> reminderTimesJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                userId: userId,
                name: name,
                description: description,
                category: category,
                iconKey: iconKey,
                colorArgb: colorArgb,
                weekdaysBitmask: weekdaysBitmask,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                dailyTarget: dailyTarget,
                dailyTargetUnit: dailyTargetUnit,
                reminderTimesJson: reminderTimesJson,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<int> weekdaysBitmask = const Value.absent(),
                Value<int?> reminderHour = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<double> dailyTarget = const Value.absent(),
                Value<String?> dailyTargetUnit = const Value.absent(),
                Value<String?> reminderTimesJson = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                description: description,
                category: category,
                iconKey: iconKey,
                colorArgb: colorArgb,
                weekdaysBitmask: weekdaysBitmask,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                dailyTarget: dailyTarget,
                dailyTargetUnit: dailyTargetUnit,
                reminderTimesJson: reminderTimesJson,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({habitCompletionsRefs = false, habitXpClaimsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (habitCompletionsRefs) db.habitCompletions,
                    if (habitXpClaimsRefs) db.habitXpClaims,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (habitCompletionsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitCompletion
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitCompletionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitXpClaimsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitXpClaim
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitXpClaimsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitXpClaimsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({
        bool habitCompletionsRefs,
        bool habitXpClaimsRefs,
      })
    >;
typedef $$HabitCompletionsTableCreateCompanionBuilder =
    HabitCompletionsCompanion Function({
      required String habitId,
      required int dateKey,
      required int completedAtMs,
      Value<double> quantity,
      Value<int> rowid,
    });
typedef $$HabitCompletionsTableUpdateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<String> habitId,
      Value<int> dateKey,
      Value<int> completedAtMs,
      Value<double> quantity,
      Value<int> rowid,
    });

final class $$HabitCompletionsTableReferences
    extends
        BaseReferences<
          _$PulseDatabase,
          $HabitCompletionsTable,
          HabitCompletion
        > {
  $$HabitCompletionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$PulseDatabase db) =>
      db.habits.createAlias(
        $_aliasNameGenerator(db.habitCompletions.habitId, db.habits.id),
      );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitCompletionsTableFilterComposer
    extends Composer<_$PulseDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitCompletionsTableOrderingComposer
    extends Composer<_$PulseDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitCompletionsTableAnnotationComposer
    extends Composer<_$PulseDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitCompletionsTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $HabitCompletionsTable,
          HabitCompletion,
          $$HabitCompletionsTableFilterComposer,
          $$HabitCompletionsTableOrderingComposer,
          $$HabitCompletionsTableAnnotationComposer,
          $$HabitCompletionsTableCreateCompanionBuilder,
          $$HabitCompletionsTableUpdateCompanionBuilder,
          (HabitCompletion, $$HabitCompletionsTableReferences),
          HabitCompletion,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitCompletionsTableTableManager(
    _$PulseDatabase db,
    $HabitCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<int> dateKey = const Value.absent(),
                Value<int> completedAtMs = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion(
                habitId: habitId,
                dateKey: dateKey,
                completedAtMs: completedAtMs,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                required int dateKey,
                required int completedAtMs,
                Value<double> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion.insert(
                habitId: habitId,
                dateKey: dateKey,
                completedAtMs: completedAtMs,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitCompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable:
                                    $$HabitCompletionsTableReferences
                                        ._habitIdTable(db),
                                referencedColumn:
                                    $$HabitCompletionsTableReferences
                                        ._habitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $HabitCompletionsTable,
      HabitCompletion,
      $$HabitCompletionsTableFilterComposer,
      $$HabitCompletionsTableOrderingComposer,
      $$HabitCompletionsTableAnnotationComposer,
      $$HabitCompletionsTableCreateCompanionBuilder,
      $$HabitCompletionsTableUpdateCompanionBuilder,
      (HabitCompletion, $$HabitCompletionsTableReferences),
      HabitCompletion,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String entity,
      required String op,
      required String payloadJson,
      required int createdAtMs,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> entity,
      Value<String> op,
      Value<String> payloadJson,
      Value<int> createdAtMs,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$PulseDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$PulseDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$PulseDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$PulseDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$PulseDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                entity: entity,
                op: op,
                payloadJson: payloadJson,
                createdAtMs: createdAtMs,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entity,
                required String op,
                required String payloadJson,
                required int createdAtMs,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                entity: entity,
                op: op,
                payloadJson: payloadJson,
                createdAtMs: createdAtMs,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$PulseDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$GamificationProfilesTableCreateCompanionBuilder =
    GamificationProfilesCompanion Function({
      required String userId,
      Value<int> totalXp,
      Value<int> level,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$GamificationProfilesTableUpdateCompanionBuilder =
    GamificationProfilesCompanion Function({
      Value<String> userId,
      Value<int> totalXp,
      Value<int> level,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$GamificationProfilesTableFilterComposer
    extends Composer<_$PulseDatabase, $GamificationProfilesTable> {
  $$GamificationProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GamificationProfilesTableOrderingComposer
    extends Composer<_$PulseDatabase, $GamificationProfilesTable> {
  $$GamificationProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamificationProfilesTableAnnotationComposer
    extends Composer<_$PulseDatabase, $GamificationProfilesTable> {
  $$GamificationProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$GamificationProfilesTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $GamificationProfilesTable,
          GamificationProfile,
          $$GamificationProfilesTableFilterComposer,
          $$GamificationProfilesTableOrderingComposer,
          $$GamificationProfilesTableAnnotationComposer,
          $$GamificationProfilesTableCreateCompanionBuilder,
          $$GamificationProfilesTableUpdateCompanionBuilder,
          (
            GamificationProfile,
            BaseReferences<
              _$PulseDatabase,
              $GamificationProfilesTable,
              GamificationProfile
            >,
          ),
          GamificationProfile,
          PrefetchHooks Function()
        > {
  $$GamificationProfilesTableTableManager(
    _$PulseDatabase db,
    $GamificationProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamificationProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamificationProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GamificationProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamificationProfilesCompanion(
                userId: userId,
                totalXp: totalXp,
                level: level,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<int> totalXp = const Value.absent(),
                Value<int> level = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => GamificationProfilesCompanion.insert(
                userId: userId,
                totalXp: totalXp,
                level: level,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GamificationProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $GamificationProfilesTable,
      GamificationProfile,
      $$GamificationProfilesTableFilterComposer,
      $$GamificationProfilesTableOrderingComposer,
      $$GamificationProfilesTableAnnotationComposer,
      $$GamificationProfilesTableCreateCompanionBuilder,
      $$GamificationProfilesTableUpdateCompanionBuilder,
      (
        GamificationProfile,
        BaseReferences<
          _$PulseDatabase,
          $GamificationProfilesTable,
          GamificationProfile
        >,
      ),
      GamificationProfile,
      PrefetchHooks Function()
    >;
typedef $$UserAchievementUnlocksTableCreateCompanionBuilder =
    UserAchievementUnlocksCompanion Function({
      required String userId,
      required String achievementKey,
      required int unlockedAtMs,
      Value<int> rowid,
    });
typedef $$UserAchievementUnlocksTableUpdateCompanionBuilder =
    UserAchievementUnlocksCompanion Function({
      Value<String> userId,
      Value<String> achievementKey,
      Value<int> unlockedAtMs,
      Value<int> rowid,
    });

class $$UserAchievementUnlocksTableFilterComposer
    extends Composer<_$PulseDatabase, $UserAchievementUnlocksTable> {
  $$UserAchievementUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get achievementKey => $composableBuilder(
    column: $table.achievementKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAtMs => $composableBuilder(
    column: $table.unlockedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAchievementUnlocksTableOrderingComposer
    extends Composer<_$PulseDatabase, $UserAchievementUnlocksTable> {
  $$UserAchievementUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get achievementKey => $composableBuilder(
    column: $table.achievementKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAtMs => $composableBuilder(
    column: $table.unlockedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAchievementUnlocksTableAnnotationComposer
    extends Composer<_$PulseDatabase, $UserAchievementUnlocksTable> {
  $$UserAchievementUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get achievementKey => $composableBuilder(
    column: $table.achievementKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unlockedAtMs => $composableBuilder(
    column: $table.unlockedAtMs,
    builder: (column) => column,
  );
}

class $$UserAchievementUnlocksTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $UserAchievementUnlocksTable,
          UserAchievementUnlock,
          $$UserAchievementUnlocksTableFilterComposer,
          $$UserAchievementUnlocksTableOrderingComposer,
          $$UserAchievementUnlocksTableAnnotationComposer,
          $$UserAchievementUnlocksTableCreateCompanionBuilder,
          $$UserAchievementUnlocksTableUpdateCompanionBuilder,
          (
            UserAchievementUnlock,
            BaseReferences<
              _$PulseDatabase,
              $UserAchievementUnlocksTable,
              UserAchievementUnlock
            >,
          ),
          UserAchievementUnlock,
          PrefetchHooks Function()
        > {
  $$UserAchievementUnlocksTableTableManager(
    _$PulseDatabase db,
    $UserAchievementUnlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAchievementUnlocksTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserAchievementUnlocksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserAchievementUnlocksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> achievementKey = const Value.absent(),
                Value<int> unlockedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserAchievementUnlocksCompanion(
                userId: userId,
                achievementKey: achievementKey,
                unlockedAtMs: unlockedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String achievementKey,
                required int unlockedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => UserAchievementUnlocksCompanion.insert(
                userId: userId,
                achievementKey: achievementKey,
                unlockedAtMs: unlockedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAchievementUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $UserAchievementUnlocksTable,
      UserAchievementUnlock,
      $$UserAchievementUnlocksTableFilterComposer,
      $$UserAchievementUnlocksTableOrderingComposer,
      $$UserAchievementUnlocksTableAnnotationComposer,
      $$UserAchievementUnlocksTableCreateCompanionBuilder,
      $$UserAchievementUnlocksTableUpdateCompanionBuilder,
      (
        UserAchievementUnlock,
        BaseReferences<
          _$PulseDatabase,
          $UserAchievementUnlocksTable,
          UserAchievementUnlock
        >,
      ),
      UserAchievementUnlock,
      PrefetchHooks Function()
    >;
typedef $$WellbeingLogsTableCreateCompanionBuilder =
    WellbeingLogsCompanion Function({
      required String id,
      required String userId,
      required int loggedAtMs,
      required int mood,
      required int energy,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WellbeingLogsTableUpdateCompanionBuilder =
    WellbeingLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> loggedAtMs,
      Value<int> mood,
      Value<int> energy,
      Value<String?> note,
      Value<int> rowid,
    });

class $$WellbeingLogsTableFilterComposer
    extends Composer<_$PulseDatabase, $WellbeingLogsTable> {
  $$WellbeingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedAtMs => $composableBuilder(
    column: $table.loggedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellbeingLogsTableOrderingComposer
    extends Composer<_$PulseDatabase, $WellbeingLogsTable> {
  $$WellbeingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedAtMs => $composableBuilder(
    column: $table.loggedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellbeingLogsTableAnnotationComposer
    extends Composer<_$PulseDatabase, $WellbeingLogsTable> {
  $$WellbeingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get loggedAtMs => $composableBuilder(
    column: $table.loggedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WellbeingLogsTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $WellbeingLogsTable,
          WellbeingLog,
          $$WellbeingLogsTableFilterComposer,
          $$WellbeingLogsTableOrderingComposer,
          $$WellbeingLogsTableAnnotationComposer,
          $$WellbeingLogsTableCreateCompanionBuilder,
          $$WellbeingLogsTableUpdateCompanionBuilder,
          (
            WellbeingLog,
            BaseReferences<_$PulseDatabase, $WellbeingLogsTable, WellbeingLog>,
          ),
          WellbeingLog,
          PrefetchHooks Function()
        > {
  $$WellbeingLogsTableTableManager(
    _$PulseDatabase db,
    $WellbeingLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellbeingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WellbeingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WellbeingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> loggedAtMs = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellbeingLogsCompanion(
                id: id,
                userId: userId,
                loggedAtMs: loggedAtMs,
                mood: mood,
                energy: energy,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required int loggedAtMs,
                required int mood,
                required int energy,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellbeingLogsCompanion.insert(
                id: id,
                userId: userId,
                loggedAtMs: loggedAtMs,
                mood: mood,
                energy: energy,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WellbeingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $WellbeingLogsTable,
      WellbeingLog,
      $$WellbeingLogsTableFilterComposer,
      $$WellbeingLogsTableOrderingComposer,
      $$WellbeingLogsTableAnnotationComposer,
      $$WellbeingLogsTableCreateCompanionBuilder,
      $$WellbeingLogsTableUpdateCompanionBuilder,
      (
        WellbeingLog,
        BaseReferences<_$PulseDatabase, $WellbeingLogsTable, WellbeingLog>,
      ),
      WellbeingLog,
      PrefetchHooks Function()
    >;
typedef $$HabitXpClaimsTableCreateCompanionBuilder =
    HabitXpClaimsCompanion Function({
      required String userId,
      required String habitId,
      required int dateKey,
      required int claimedAtMs,
      Value<int> rowid,
    });
typedef $$HabitXpClaimsTableUpdateCompanionBuilder =
    HabitXpClaimsCompanion Function({
      Value<String> userId,
      Value<String> habitId,
      Value<int> dateKey,
      Value<int> claimedAtMs,
      Value<int> rowid,
    });

final class $$HabitXpClaimsTableReferences
    extends BaseReferences<_$PulseDatabase, $HabitXpClaimsTable, HabitXpClaim> {
  $$HabitXpClaimsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$PulseDatabase db) =>
      db.habits.createAlias(
        $_aliasNameGenerator(db.habitXpClaims.habitId, db.habits.id),
      );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitXpClaimsTableFilterComposer
    extends Composer<_$PulseDatabase, $HabitXpClaimsTable> {
  $$HabitXpClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get claimedAtMs => $composableBuilder(
    column: $table.claimedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitXpClaimsTableOrderingComposer
    extends Composer<_$PulseDatabase, $HabitXpClaimsTable> {
  $$HabitXpClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get claimedAtMs => $composableBuilder(
    column: $table.claimedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitXpClaimsTableAnnotationComposer
    extends Composer<_$PulseDatabase, $HabitXpClaimsTable> {
  $$HabitXpClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get claimedAtMs => $composableBuilder(
    column: $table.claimedAtMs,
    builder: (column) => column,
  );

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitXpClaimsTableTableManager
    extends
        RootTableManager<
          _$PulseDatabase,
          $HabitXpClaimsTable,
          HabitXpClaim,
          $$HabitXpClaimsTableFilterComposer,
          $$HabitXpClaimsTableOrderingComposer,
          $$HabitXpClaimsTableAnnotationComposer,
          $$HabitXpClaimsTableCreateCompanionBuilder,
          $$HabitXpClaimsTableUpdateCompanionBuilder,
          (HabitXpClaim, $$HabitXpClaimsTableReferences),
          HabitXpClaim,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitXpClaimsTableTableManager(
    _$PulseDatabase db,
    $HabitXpClaimsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitXpClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitXpClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitXpClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<int> dateKey = const Value.absent(),
                Value<int> claimedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitXpClaimsCompanion(
                userId: userId,
                habitId: habitId,
                dateKey: dateKey,
                claimedAtMs: claimedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String habitId,
                required int dateKey,
                required int claimedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => HabitXpClaimsCompanion.insert(
                userId: userId,
                habitId: habitId,
                dateKey: dateKey,
                claimedAtMs: claimedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitXpClaimsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitXpClaimsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitXpClaimsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitXpClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$PulseDatabase,
      $HabitXpClaimsTable,
      HabitXpClaim,
      $$HabitXpClaimsTableFilterComposer,
      $$HabitXpClaimsTableOrderingComposer,
      $$HabitXpClaimsTableAnnotationComposer,
      $$HabitXpClaimsTableCreateCompanionBuilder,
      $$HabitXpClaimsTableUpdateCompanionBuilder,
      (HabitXpClaim, $$HabitXpClaimsTableReferences),
      HabitXpClaim,
      PrefetchHooks Function({bool habitId})
    >;

class $PulseDatabaseManager {
  final _$PulseDatabase _db;
  $PulseDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(_db, _db.habitCompletions);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$GamificationProfilesTableTableManager get gamificationProfiles =>
      $$GamificationProfilesTableTableManager(_db, _db.gamificationProfiles);
  $$UserAchievementUnlocksTableTableManager get userAchievementUnlocks =>
      $$UserAchievementUnlocksTableTableManager(
        _db,
        _db.userAchievementUnlocks,
      );
  $$WellbeingLogsTableTableManager get wellbeingLogs =>
      $$WellbeingLogsTableTableManager(_db, _db.wellbeingLogs);
  $$HabitXpClaimsTableTableManager get habitXpClaims =>
      $$HabitXpClaimsTableTableManager(_db, _db.habitXpClaims);
}
