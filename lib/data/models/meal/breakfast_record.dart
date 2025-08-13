import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/models/meal/meal_record.dart';

/// Завтрак
class BreakfastRecord extends MealRecord {
  const BreakfastRecord({
    required super.id,
    required super.date,
    required super.products,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BreakfastRecord.create({required DateTime date}) {
    final now = DateTime.now();
    return BreakfastRecord(
      id: now.millisecondsSinceEpoch.toString(),
      date: date,
      products: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  BreakfastRecord addProduct(FoodProduct product) {
    return copyWith(
      products: [...products, product],
      updatedAt: DateTime.now(),
    );
  }

  @override
  BreakfastRecord removeProduct(String productId) {
    return copyWith(
      products: products.where((p) => p.id != productId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  BreakfastRecord copyWith({
    String? id,
    DateTime? date,
    List<FoodProduct>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreakfastRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': 'breakfast',
    };
  }

  factory BreakfastRecord.fromJson(Map<String, dynamic> json) {
    return BreakfastRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      products: (json['products'] as List)
          .map((p) => FoodProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
