import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

/// Абстрактная модель для приема пищи
abstract class MealRecord extends Equatable {
  final String id;
  final DateTime date; // Дата приема пищи
  final List<FoodProduct> products; // Список продуктов
  final DateTime createdAt; // Дата создания записи
  final DateTime updatedAt; // Дата последнего обновления

  const MealRecord({
    required this.id,
    required this.date,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Получить общие калории приема пищи
  int get totalCalories =>
      products.fold<int>(0, (sum, product) => sum + product.totalCalories);

  /// Получить количество продуктов
  int get productsCount => products.length;

  /// Добавить продукт
  MealRecord addProduct(FoodProduct product);

  /// Удалить продукт
  MealRecord removeProduct(String productId);

  /// Получить отображаемые калории
  String get displayCalories => '$totalCalories ккал';

  /// Получить отображаемую дату
  String get displayDate => '${date.day}.${date.month}.${date.year}';

  @override
  List<Object?> get props => [id, date, products, createdAt, updatedAt];
}
