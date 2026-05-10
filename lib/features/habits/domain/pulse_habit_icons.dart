import 'package:flutter/material.dart';

const List<String> kPulseHabitIconKeys = [
  'task_alt',
  'fitness_center',
  'book',
  'water_drop',
  'bedtime',
  'self_improvement',
  'restaurant',
  'computer',
  'music_note',
  'pets',
  'savings',
  'favorite',
];

IconData pulseHabitIcon(String key) {
  switch (key) {
    case 'fitness_center':
      return Icons.fitness_center_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'water_drop':
      return Icons.water_drop_rounded;
    case 'bedtime':
      return Icons.bedtime_rounded;
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'computer':
      return Icons.computer_rounded;
    case 'music_note':
      return Icons.music_note_rounded;
    case 'pets':
      return Icons.pets_rounded;
    case 'savings':
      return Icons.savings_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'task_alt':
    default:
      return Icons.task_alt_rounded;
  }
}
