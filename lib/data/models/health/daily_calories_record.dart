import 'package:equatable/equatable.dart';

/// Модель дневной записи калорий
class DailyCaloriesRecord extends Equatable {
  final String id;
  final DateTime date;
  final int consumedCalories; // Съедено калорий
  final int burnedCalories; // Сожжено калорий (базовый обмен)
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyCaloriesRecord({
    required this.id,
    required this.date,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyCaloriesRecord.create({
    required DateTime date,
    required int burnedCalories,
  }) {
    final now = DateTime.now();
    return DailyCaloriesRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      consumedCalories: 0, // По умолчанию 0
      burnedCalories: burnedCalories,
      createdAt: now,
      updatedAt: now,
    );
  }

  DailyCaloriesRecord copyWith({
    String? id,
    DateTime? date,
    int? consumedCalories,
    int? burnedCalories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyCaloriesRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
  int get maxCalories =>
      (burnedCalories * 1.2).round(); // 120% от базового обмена

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
  ];
}
