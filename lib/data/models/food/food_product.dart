import 'package:equatable/equatable.dart';

/// Модель продукта питания
class FoodProduct extends Equatable {
  final String id;
  final String name;
  final String? barcode; // Код если отсканировали
  final double amount; // Количество в граммах или миллилитрах
  final String unit; // Единица измерения (г, мл)
  final int caloriesPer100; // Калории на 100г/100мл
  final DateTime timestamp; // Время добавления в прием пищи
  final int usageCount; // Счетчик сколько раз добавляли продукт
  final DateTime createdAt; // Дата создания продукта
  final bool isFavorite; // НОВОЕ: избранный продукт

  const FoodProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.amount,
    required this.unit,
    required this.caloriesPer100,
    required this.timestamp,
    required this.usageCount,
    required this.createdAt,
    required this.isFavorite, // НОВОЕ
  });

  factory FoodProduct.create({
    required String name,
    String? barcode,
    required double amount,
    required String unit,
    required int caloriesPer100,
  }) {
    final now = DateTime.now();
    return FoodProduct(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      barcode: barcode,
      amount: amount,
      unit: unit,
      caloriesPer100: caloriesPer100,
      timestamp: now,
      usageCount: 1,
      createdAt: now,
      isFavorite: false, // НОВОЕ: по умолчанию не избранный
    );
  }

  /// Получить общие калории продукта
  int get totalCalories => ((amount * caloriesPer100) / 100).round();

  /// Получить отображаемое количество с единицей
  String get displayAmount => '${amount.toStringAsFixed(1)} $unit';

  /// Получить отображаемые калории
  String get displayCalories => '$totalCalories ккал';

  /// Увеличить счетчик использования
  FoodProduct incrementUsage() {
    return copyWith(usageCount: usageCount + 1, timestamp: DateTime.now());
  }

  /// Переключить избранное
  FoodProduct toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  /// Получить отображаемый счетчик использования
  String get displayUsageCount => 'Использован $usageCount раз';

  FoodProduct copyWith({
    String? id,
    String? name,
    String? barcode,
    double? amount,
    String? unit,
    int? caloriesPer100,
    DateTime? timestamp,
    int? usageCount,
    DateTime? createdAt,
    bool? isFavorite, // НОВОЕ
  }) {
    return FoodProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      caloriesPer100: caloriesPer100 ?? this.caloriesPer100,
      timestamp: timestamp ?? this.timestamp,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite, // НОВОЕ
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
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite, // НОВОЕ
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
      usageCount: json['usageCount'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false, // НОВОЕ
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
    usageCount,
    createdAt,
    isFavorite, // НОВОЕ
  ];
}

/// Типы приемов пищи
enum MealType {
  breakfast, // Завтрак
  lunch, // Обед
  dinner, // Ужин
  snack; // Перекус

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
