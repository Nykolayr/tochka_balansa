import 'package:equatable/equatable.dart';

/// Модель дневной записи калорий
class DailyCaloriesRecord extends Equatable {
  final String id;
  final DateTime date;
  final int consumedCalories; // Съедено калорий
  final int burnedCalories; // Сожжено калорий (базовый обмен)
  final DateTime createdAt;
  final DateTime updatedAt;
  final String gender; // НОВОЕ: добавляем пол для расчета maxValue

  const DailyCaloriesRecord({
    required this.id,
    required this.date,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.createdAt,
    required this.updatedAt,
    required this.gender, // НОВОЕ
  });

  factory DailyCaloriesRecord.create({
    required DateTime date,
    required int burnedCalories,
    required String gender, // НОВОЕ
  }) {
    final now = DateTime.now();
    return DailyCaloriesRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      consumedCalories: 0, // По умолчанию 0
      burnedCalories: burnedCalories,
      createdAt: now,
      updatedAt: now,
      gender: gender, // НОВОЕ
    );
  }

  DailyCaloriesRecord copyWith({
    String? id,
    DateTime? date,
    int? consumedCalories,
    int? burnedCalories,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? gender, // НОВОЕ
  }) {
    return DailyCaloriesRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender, // НОВОЕ
    );
  }

  /// Добавить калории к съеденным
  DailyCaloriesRecord addConsumedCalories(int calories) {
    return copyWith(
      consumedCalories: consumedCalories + calories,
      updatedAt: DateTime.now(),
    );
  }

  /// Добавить калории к сожженным
  DailyCaloriesRecord addBurnedCalories(int calories) {
    return copyWith(
      burnedCalories: burnedCalories + calories,
      updatedAt: DateTime.now(),
    );
  }

  /// Получить баланс калорий (съедено - сожжено)
  int get balance => consumedCalories - burnedCalories;

  /// Получить максимальное количество калорий для 100% заполнения сосуда
  /// Женщины: максимум 3500, мужчины: максимум 4000
  int get maxCalories {
    if (gender == 'female') {
      return 3200; // Максимум для женщин
    } else {
      return 3800; // Максимум для мужчин
    }
  }

  /// Процент заполнения сосуда "Съедено"
  double get consumedPercentage => consumedCalories / maxCalories;

  /// Процент заполнения сосуда "Сожжено"
  double get burnedPercentage => burnedCalories / maxCalories;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'consumedCalories': consumedCalories,
      'burnedCalories': burnedCalories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'gender': gender, // НОВОЕ
    };
  }

  factory DailyCaloriesRecord.fromJson(Map<String, dynamic> json) {
    return DailyCaloriesRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      consumedCalories: json['consumedCalories'] as int,
      burnedCalories: json['burnedCalories'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      gender: json['gender'] as String? ?? 'male', // НОВОЕ: по умолчанию male
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    consumedCalories,
    burnedCalories,
    createdAt,
    updatedAt,
    gender, // НОВОЕ
  ];
}
