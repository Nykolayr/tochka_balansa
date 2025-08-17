part of 'food_bloc.dart';

class FoodState extends Equatable {
  final bool isLoading;
  final String error;
  final bool isListChange;

  // Списки продуктов по табам
  final List<FoodProduct> recentProducts;
  final List<FoodProduct> frequentProducts;
  final List<FoodProduct> favoriteProducts;

  // поиск
  final List<FoodProduct> searchProducts;
  // Списки продуктов по категориям
  final List<FoodProduct> breakfastProducts;
  final List<FoodProduct> lunchProducts;
  final List<FoodProduct> dinnerProducts;
  final List<FoodProduct> snackProducts;

  const FoodState({
    required this.isLoading,
    required this.error,
    required this.isListChange,
    required this.recentProducts,
    required this.frequentProducts,
    required this.searchProducts,
    required this.breakfastProducts,
    required this.lunchProducts,
    required this.dinnerProducts,
    required this.snackProducts,
    required this.favoriteProducts,
  });

  FoodState copyWith({
    bool? isLoading,
    String? error,
    bool? isListChange,
    List<FoodProduct>? recentProducts,
    List<FoodProduct>? frequentProducts,
    List<FoodProduct>? breakfastProducts,
    List<FoodProduct>? searchProducts,
    List<FoodProduct>? lunchProducts,
    List<FoodProduct>? dinnerProducts,
    List<FoodProduct>? snackProducts,
    List<FoodProduct>? favoriteProducts,
  }) {
    // Если изменился хотя бы один из списков, инвертируем isListChange
    bool hasListChanged =
        recentProducts != null ||
        frequentProducts != null ||
        breakfastProducts != null ||
        searchProducts != null ||
        lunchProducts != null ||
        dinnerProducts != null ||
        snackProducts != null ||
        favoriteProducts != null;
    bool newIsListChange = hasListChanged
        ? !(isListChange ?? false)
        : (isListChange ?? this.isListChange);
    return FoodState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isListChange: newIsListChange,
      recentProducts: recentProducts ?? this.recentProducts,
      frequentProducts: frequentProducts ?? this.frequentProducts,
      breakfastProducts: breakfastProducts ?? this.breakfastProducts,
      searchProducts: searchProducts ?? this.searchProducts,
      lunchProducts: lunchProducts ?? this.lunchProducts,
      dinnerProducts: dinnerProducts ?? this.dinnerProducts,
      snackProducts: snackProducts ?? this.snackProducts,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
    );
  }

  factory FoodState.initial() => FoodState(
    isLoading: false,
    error: '',
    isListChange: false,
    recentProducts: [],
    frequentProducts: [],
    favoriteProducts: [],
    searchProducts: [],
    breakfastProducts: Get.find<DailyCaloriesRepository>()
        .getTodayRecord(DateTime.now())
        .breakfast,
    lunchProducts: Get.find<DailyCaloriesRepository>()
        .getTodayRecord(DateTime.now())
        .lunch,
    dinnerProducts: Get.find<DailyCaloriesRepository>()
        .getTodayRecord(DateTime.now())
        .dinner,
    snackProducts: Get.find<DailyCaloriesRepository>()
        .getTodayRecord(DateTime.now())
        .snacks,
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    isListChange,
    recentProducts,
    frequentProducts,
    breakfastProducts,
    searchProducts,
    lunchProducts,
    dinnerProducts,
    snackProducts,
    favoriteProducts,
  ];
}
