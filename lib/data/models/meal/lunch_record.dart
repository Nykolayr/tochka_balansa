import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/models/meal/meal_record.dart';

/// Обед
class LunchRecord extends MealRecord {
  const LunchRecord({
    required super.id,
    required super.date,
    required super.products,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LunchRecord.create({required DateTime date}) {
    final now = DateTime.now();
    return LunchRecord(
      id: now.millisecondsSinceEpoch.toString(),
      date: date,
      products: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  LunchRecord addProduct(FoodProduct product) {
    return copyWith(
      products: [...products, product],
      updatedAt: DateTime.now(),
    );
  }

  @override
  LunchRecord removeProduct(String productId) {
    return copyWith(
      products: products.where((p) => p.id != productId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  LunchRecord copyWith({
    String? id,
    DateTime? date,
    List<FoodProduct>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LunchRecord(
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
      'type': 'lunch',
    };
  }

  factory LunchRecord.fromJson(Map<String, dynamic> json) {
    return LunchRecord(
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
