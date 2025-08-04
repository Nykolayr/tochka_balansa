import 'package:flutter/material.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

class DefaultGoalTypes {
  static List<AdditionalGoal> get defaultTypes => [
    AdditionalGoal(
      id: 'medication',
      title: textLang('Прием лекарств'),
      description: textLang('Отслеживание приема лекарств'),
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: 1,
      unit: textLang('таблеток'),
      goalTo: textLang('лекарство'),
      reminderText: 'Время принять лекарство!',
      icon: Icons.medication,
    ),
    AdditionalGoal(
      id: 'reading',
      title: textLang('Чтение'),
      description: textLang('Чтение книг и статей'),
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: 20,
      unit: textLang('страниц'),
      goalTo: textLang('книга'),
      reminderText: 'Время для чтения!',
      icon: Icons.book,
    ),
    AdditionalGoal(
      id: 'exercise',
      title: textLang('Упражнения'),
      description: textLang('Физические упражнения'),
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: 30,
      unit: textLang('повторений'),
      goalTo: textLang('упражнение'),
      reminderText: 'Время для тренировки!',
      icon: Icons.fitness_center,
    ),
    AdditionalGoal(
      id: 'water',
      title: textLang('Пить воду'),
      description: textLang('Потребление воды'),
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: 2,
      unit: textLang('литров'),
      goalTo: textLang('вода'),
      reminderText: 'Не забудьте выпить воду!',
      icon: Icons.water_drop,
    ),
    AdditionalGoal(
      id: 'custom',
      title: textLang('Своя цель'),
      description: textLang('Создание собственной цели'),
      createdAt: DateTime.now(),
      deadlineType: DeadlineType.fixed,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      targetCount: 1,
      unit: textLang('единиц'),
      goalTo: textLang('цель'),
      reminderText: 'Время для вашей цели!',
      icon: Icons.add_task,
    ),
  ];
}
