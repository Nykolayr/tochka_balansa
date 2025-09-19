import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

/// Модель дневной записи калорий
class DailyCaloriesRecord extends Equatable {
  final String id;
  final DateTime date;
  final int consumedCalories; // Съедено калорий
  final int burnedCalories; // Сожжено калорий (от упражнений)
  final int maxCalories; // Максимальные калории (BMR + активность)
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FoodProduct> breakfast;
  final List<FoodProduct> lunch;
  final List<FoodProduct> dinner;
  final List<FoodProduct> snacks;

  const DailyCaloriesRecord({
    required this.id,
    required this.date,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.maxCalories,
    required this.createdAt,
    required this.updatedAt,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });

  factory DailyCaloriesRecord.create({
    required DateTime date,
    required int burnedCalories,
    required int maxCalories,
    required String gender,
  }) {
    final now = DateTime.now();
    return DailyCaloriesRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      consumedCalories: 0, // По умолчанию 0
      burnedCalories: burnedCalories,
      maxCalories: maxCalories,
      createdAt: now,
      updatedAt: now,
      breakfast: [],
      lunch: [],
      dinner: [],
      snacks: [],
    );
  }

  DailyCaloriesRecord copyWith({
    String? id,
    DateTime? date,
    int? consumedCalories,
    int? burnedCalories,
    int? maxCalories,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FoodProduct>? breakfast,
    List<FoodProduct>? lunch,
    List<FoodProduct>? dinner,
    List<FoodProduct>? snacks,
  }) {
    return DailyCaloriesRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      maxCalories: maxCalories ?? this.maxCalories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
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
  /// Теперь используется сохраненное значение maxCalories

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
      'maxCalories': maxCalories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'breakfast': breakfast.map((e) => e.toJson()).toList(),
      'lunch': lunch.map((e) => e.toJson()).toList(),
      'dinner': dinner.map((e) => e.toJson()).toList(),
      'snacks': snacks.map((e) => e.toJson()).toList(),
    };
  }

  factory DailyCaloriesRecord.fromJson(Map<String, dynamic> json) {
    return DailyCaloriesRecord(
      id: json['id'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      consumedCalories: json['consumedCalories'] ?? 0,
      burnedCalories: json['burnedCalories'] ?? 0,
      maxCalories: json['maxCalories'] ?? 2000, // Базовое значение по умолчанию
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      breakfast:
          (json['breakfast'] as List<dynamic>?)
              ?.map((e) => FoodProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lunch:
          (json['lunch'] as List<dynamic>?)
              ?.map((e) => FoodProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dinner:
          (json['dinner'] as List<dynamic>?)
              ?.map((e) => FoodProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      snacks:
          (json['snacks'] as List<dynamic>?)
              ?.map((e) => FoodProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    consumedCalories,
    burnedCalories,
    maxCalories,
    createdAt,
    updatedAt,
    breakfast,
    lunch,
    dinner,
    snacks,
  ];
}
