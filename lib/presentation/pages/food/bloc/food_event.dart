part of 'food_bloc.dart';

sealed class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object> get props => [];
}

class AddProductToBreakfast extends FoodEvent {
  final FoodProduct product;

  const AddProductToBreakfast(this.product);

  @override
  List<Object> get props => [product];
}

class AddProductToRecent extends FoodEvent {
  final FoodProduct product;

  const AddProductToRecent(this.product);

  @override
  List<Object> get props => [product];
}

class AddProductToFrequent extends FoodEvent {
  final FoodProduct product;

  const AddProductToFrequent(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateSearchProducts extends FoodEvent {
  final List<FoodProduct> products;

  const UpdateSearchProducts(this.products);

  @override
  List<Object> get props => [products];
}
