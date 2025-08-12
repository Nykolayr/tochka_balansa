import 'package:equatable/equatable.dart';

/// Модель продукта питания
class FoodProduct extends Equatable {
  final String id;
  final String name;
  final String? barcode; // Код если отсканировали
  final double amount; // Количество в граммах или миллилитрах
  final String unit; // Единица измерения (г, мл)
  final int caloriesPer100; // Калории на 100г/100мл
  final DateTime timestamp;
  final String mealType; // Тип приема пищи (breakfast, lunch, dinner, snack)

  const FoodProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.amount,
    required this.unit,
    required this.caloriesPer100,
    required this.timestamp,
    required this.mealType,
  });

  factory FoodProduct.create({
    required String name,
    String? barcode,
    required double amount,
    required String unit,
    required int caloriesPer100,
    required String mealType,
  }) {
    return FoodProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      barcode: barcode,
      amount: amount,
      unit: unit,
      caloriesPer100: caloriesPer100,
      timestamp: DateTime.now(),
      mealType: mealType,
    );
  }

  /// Получить общие калории продукта
  int get totalCalories => ((amount * caloriesPer100) / 100).round();

  /// Получить отображаемое количество с единицей
  String get displayAmount => '${amount.toStringAsFixed(1)} $unit';

  /// Получить отображаемые калории
  String get displayCalories => '$totalCalories ккал';

  FoodProduct copyWith({
    String? id,
    String? name,
    String? barcode,
    double? amount,
    String? unit,
    int? caloriesPer100,
    DateTime? timestamp,
    String? mealType,
  }) {
    return FoodProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      caloriesPer100: caloriesPer100 ?? this.caloriesPer100,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'amount': amount,
      'unit': unit,
      'caloriesPer100': caloriesPer100,
      'timestamp': timestamp.toIso8601String(),
      'mealType': mealType,
    };
  }

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    return FoodProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      caloriesPer100: json['caloriesPer100'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mealType: json['mealType'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    barcode,
    amount,
    unit,
    caloriesPer100,
    timestamp,
    mealType,
  ];
}

/// Типы приемов пищи
enum MealType {
  breakfast, // Завтрак
  lunch,     // Обед
  dinner,    // Ужин
  snack;     // Перекус

  String get title => switch (this) {
    breakfast => 'Завтрак',
    lunch => 'Обед',
    dinner => 'Ужин',
    snack => 'Перекус',
  };

  String get value => switch (this) {
    breakfast => 'breakfast',
    lunch => 'lunch',
    dinner => 'dinner',
    snack => 'snack',
  };
} 