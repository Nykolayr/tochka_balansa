import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/workout_goal.dart';
import 'package:tochka_balansa/data/models/goal/supplement_goal.dart';
import 'package:tochka_balansa/data/models/goal/sleep_goal.dart';

/// Модель пользователя
class User extends Equatable {
  final int id;
  final String name;
  final DateTime birthDate;
  final String email;
  final Gender gender;
  final double initialWeight;
  final double height;
  final String language; // 'en' или 'ru'
  final List<AdditionalGoal> additionalGoals;

  bool get isReg => name.isNotEmpty;

  const User({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.email,
    required this.gender,
    required this.initialWeight,
    required this.height,
    this.language = 'ru', // По умолчанию русский
    this.additionalGoals = const [],
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
    additionalGoals: const [],
  );

  factory User.fromJson(Map<String, dynamic> json) {
    final additionalGoalsJson = json['additionalGoals'] as List<dynamic>? ?? [];
    final additionalGoals = additionalGoalsJson.map((goalJson) {
      final goalMap = goalJson as Map<String, dynamic>;
      final type = goalMap['type'] as String?;

      switch (type) {
        case 'workout':
          return WorkoutGoal.fromJson(goalMap);
        case 'supplement':
          return SupplementGoal.fromJson(goalMap);
        case 'sleep':
          return SleepGoal.fromJson(goalMap);
        default:
          return WorkoutGoal.init(); // fallback
      }
    }).toList();

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
      additionalGoals: additionalGoals,
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
      'additionalGoals': additionalGoals.map((goal) => goal.toJson()).toList(),
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
    List<AdditionalGoal>? additionalGoals,
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
      additionalGoals: additionalGoals ?? this.additionalGoals,
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
    additionalGoals,
  ];
}
