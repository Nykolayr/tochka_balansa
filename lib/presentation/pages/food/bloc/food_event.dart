part of 'food_bloc.dart';

sealed class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object> get props => [];
}

/// Добавляем продукт в завтрак
class AddProductToBreakfast extends FoodEvent {
  final FoodProduct product;

  const AddProductToBreakfast(this.product);

  @override
  List<Object> get props => [product];
}

/// Добавляем продукт в обед
class AddProductToLunch extends FoodEvent {
  final FoodProduct product;

  const AddProductToLunch(this.product);

  @override
  List<Object> get props => [product];
}

/// Добавляем продукт в ужин
class AddProductToDinner extends FoodEvent {
  final FoodProduct product;

  const AddProductToDinner(this.product);

  @override
  List<Object> get props => [product];
}

/// Добавляем продукт в перекус
class AddProductToSnack extends FoodEvent {
  final FoodProduct product;

  const AddProductToSnack(this.product);

  @override
  List<Object> get props => [product];
}

/// Добавляем продукт в прием пищи
class AddProductToRecent extends FoodEvent {
  final FoodProduct product;

  const AddProductToRecent(this.product);

  @override
  List<Object> get props => [product];
}

/// Добавляем продукт в часто используемые
class AddProductToFrequent extends FoodEvent {
  final FoodProduct product;

  const AddProductToFrequent(this.product);

  @override
  List<Object> get props => [product];
}

/// Обновляем список продуктов
class UpdateSearchProducts extends FoodEvent {
  final List<FoodProduct> products;

  const UpdateSearchProducts(this.products);

  @override
  List<Object> get props => [products];
}
