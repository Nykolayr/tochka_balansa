part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;
  final int selectedIndex;
  final int consumedCalories;
  final int burnedCalories;
  final int maxCalories;
  final List<FoodProduct> foodProducts; // НОВОЕ: список продуктов

  bool get isReg => user.name.isNotEmpty;

  const MainState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
    required this.selectedIndex,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.maxCalories,
    required this.foodProducts, // НОВОЕ
  });

  MainState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    int? selectedIndex,
    int? consumedCalories,
    int? burnedCalories,
    int? maxCalories,
    List<FoodProduct>? foodProducts, // НОВОЕ
  }) {
    final shouldToggleList = user != null;

    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isListChange: shouldToggleList ? !isListChange : this.isListChange,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      maxCalories: maxCalories ?? this.maxCalories,
      foodProducts: foodProducts ?? this.foodProducts, // НОВОЕ
    );
  }

  factory MainState.initial() => MainState(
    isLoading: false,
    error: '',
    user: Get.find<UserRepository>().user,
    isListChange: false,
    selectedIndex: 0,
    consumedCalories: 0,
    burnedCalories: 0,
    maxCalories: 2000,
    foodProducts: [], // НОВОЕ
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    user,
    isListChange,
    selectedIndex,
    consumedCalories,
    burnedCalories,
    maxCalories,
    foodProducts, // НОВОЕ
  ];
}
