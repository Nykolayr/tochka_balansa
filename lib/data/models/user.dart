import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';

import 'package:tochka_balansa/data/models/goal/user_goal.dart';
import 'package:tochka_balansa/data/models/health/activity_level.dart';

/// Модель пользователя
class User extends Equatable {
  final int id;
  final String name;
  final DateTime birthDate;
  final String email;
  final Gender gender;
  final double initialWeight;
  final double height;
  final String language;
  final ActivityLevel activityLevel; // НОВОЕ поле
  final List<AdditionalGoal> additionalGoals;
  final UserGoal mainGoal;

  bool get isReg => name.isNotEmpty;

  const User({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.email,
    required this.gender,
    required this.initialWeight,
    required this.height,
    required this.language,
    required this.activityLevel, // НОВОЕ поле
    required this.additionalGoals,
    required this.mainGoal,
  });

  factory User.initial() => User(
    id: 0,
    name: '',
    birthDate: DateTime(2000, 1, 1),
    email: '',
    gender: Gender.male,
    initialWeight: 0.0,
    height: 0.0,
    language: 'ru',
    activityLevel: ActivityLevel.sedentary, // По умолчанию сидячий
    additionalGoals: const [],
    mainGoal: UserGoal.init(),
  );

  factory User.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> additionalJsonGoals = [];
    List<AdditionalGoal> additionalGoals = [];
    try {
      if (json.containsKey('additionalGoals') &&
          json['additionalGoals'] is List) {
        additionalJsonGoals = List<Map<String, dynamic>>.from(
          json['additionalGoals'].map((e) => Map<String, dynamic>.from(e)),
        );
      }
      additionalGoals = additionalJsonGoals
          .map(
            (goal) => AdditionalGoal.fromJson(Map<String, dynamic>.from(goal)),
          )
          .toList();
    } catch (e) {
      Logger.e('User.fromJson: Ошибка при создании additionalGoals: $e');
    }

    // Обрабатываем mainGoal
    UserGoal mainGoal;
    try {
      final mainGoalData = json['mainGoal'];
      if (mainGoalData != null && mainGoalData is Map) {
        final convertedMainGoal = Map<String, dynamic>.from(mainGoalData);
        mainGoal = UserGoal.fromJson(convertedMainGoal);
      } else {
        mainGoal = UserGoal.init();
      }
    } catch (e) {
      Logger.e('User.fromJson: Ошибка при создании mainGoal: $e');
      mainGoal = UserGoal.init();
    }

    // Обрабатываем activityLevel
    ActivityLevel activityLevel;
    try {
      final activityLevelStr = json['activityLevel'] as String?;
      if (activityLevelStr != null) {
        activityLevel = ActivityLevel.values.firstWhere(
          (e) => e.name == activityLevelStr,
        );
      } else {
        activityLevel = ActivityLevel.sedentary;
      }
    } catch (e) {
      Logger.e('User.fromJson: Ошибка при создании activityLevel: $e');
      activityLevel = ActivityLevel.sedentary;
    }

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : DateTime(2000, 1, 1),
      email: json['email'] ?? '',
      gender: json['gender'] == 'female' ? Gender.female : Gender.male,
      initialWeight: (json['initialWeight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      language: json['language'] ?? 'ru',
      activityLevel: activityLevel, // НОВОЕ поле
      additionalGoals: additionalGoals,
      mainGoal: mainGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'email': email,
      'gender': gender.name,
      'initialWeight': initialWeight,
      'height': height,
      'language': language,
      'activityLevel': activityLevel.name, // НОВОЕ поле
      'additionalGoals': additionalGoals.map((goal) => goal.toJson()).toList(),
      'mainGoal': mainGoal.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    String? email,
    Gender? gender,
    double? initialWeight,
    double? height,
    String? language,
    ActivityLevel? activityLevel, // НОВОЕ поле
    List<AdditionalGoal>? additionalGoals,
    UserGoal? mainGoal,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      initialWeight: initialWeight ?? this.initialWeight,
      height: height ?? this.height,
      language: language ?? this.language,
      activityLevel: activityLevel ?? this.activityLevel, // НОВОЕ поле
      additionalGoals: additionalGoals ?? this.additionalGoals,
      mainGoal: mainGoal ?? this.mainGoal,
    );
  }

  /// возраст пользователя, вычисляется из даты рождения
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    birthDate,
    age,
    email,
    gender,
    initialWeight,
    height,
    language,
    activityLevel, // НОВОЕ поле
    additionalGoals,
    mainGoal,
  ];
}
