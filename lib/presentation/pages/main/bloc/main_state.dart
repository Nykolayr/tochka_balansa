part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;
  final int selectedIndex;
  final int consumedCalories; // НОВОЕ: съедено калорий
  final int burnedCalories;   // НОВОЕ: сожжено калорий
  final int maxCalories;      // НОВОЕ: максимальное количество калорий

  bool get isReg => user.name.isNotEmpty;
  
  const MainState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
    required this.selectedIndex,
    required this.consumedCalories, // НОВОЕ
    required this.burnedCalories,   // НОВОЕ
    required this.maxCalories,      // НОВОЕ
  });

  MainState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    int? selectedIndex,
    int? consumedCalories, // НОВОЕ
    int? burnedCalories,   // НОВОЕ
    int? maxCalories,      // НОВОЕ
  }) {
    final shouldToggleList = user != null;

    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isListChange: shouldToggleList ? !isListChange : isListChange,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      consumedCalories: consumedCalories ?? this.consumedCalories, // НОВОЕ
      burnedCalories: burnedCalories ?? this.burnedCalories,       // НОВОЕ
      maxCalories: maxCalories ?? this.maxCalories,               // НОВОЕ
    );
  }

  factory MainState.initial() => MainState(
    isLoading: false,
    error: '',
    user: Get.find<UserRepository>().user,
    isListChange: false,
    selectedIndex: 0,
    consumedCalories: 0,    // НОВОЕ: по умолчанию 0
    burnedCalories: 0,      // НОВОЕ: по умолчанию 0
    maxCalories: 2000,      // НОВОЕ: по умолчанию 2000
  );

  @override
  List<Object?> get props => [
    isLoading,
    error,
    user,
    isListChange,
    selectedIndex,
    consumedCalories, // НОВОЕ
    burnedCalories,   // НОВОЕ
    maxCalories,      // НОВОЕ
  ];
}
