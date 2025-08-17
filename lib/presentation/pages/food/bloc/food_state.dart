part of 'food_bloc.dart';

class FoodState extends Equatable {
  final bool isLoading;
  final String error;
  final bool isListChange;

  // Списки продуктов по категориям
  final List<FoodProduct> recentProducts;
  final List<FoodProduct> frequentProducts;
  final List<FoodProduct> breakfastProducts;
  final List<FoodProduct> searchProducts;
  final List<FoodProduct> lunchProducts;
  final List<FoodProduct> dinnerProducts;
  final List<FoodProduct> snackProducts;

  const FoodState({
    required this.isLoading,
    required this.error,
    required this.isListChange,
    this.recentProducts = const [],
    this.frequentProducts = const [],
    this.breakfastProducts = const [],
    this.searchProducts = const [],
    this.lunchProducts = const [],
    this.dinnerProducts = const [],
    this.snackProducts = const [],
  });

  FoodState copyWith({
    bool? isLoading,
    String? error,
    bool? isListChange,
    List<FoodProduct>? recentProducts,
    List<FoodProduct>? frequentProducts,
    List<FoodProduct>? breakfastProducts,
    List<FoodProduct>? searchProducts,
  }) {
    bool hasChanges =
        recentProducts != null ||
        frequentProducts != null ||
        breakfastProducts != null ||
        searchProducts != null;
    return FoodState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isListChange: isListChange ?? hasChanges,
      recentProducts: recentProducts ?? this.recentProducts,
      frequentProducts: frequentProducts ?? this.frequentProducts,
      breakfastProducts: breakfastProducts ?? this.breakfastProducts,
    );
  }

  factory FoodState.initial() => FoodState(
    isLoading: false,
    error: '',
    isListChange: false,
    recentProducts: [],
    frequentProducts: [],
    breakfastProducts: [],
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    isListChange,
    recentProducts,
    frequentProducts,
    breakfastProducts,
  ];
}
