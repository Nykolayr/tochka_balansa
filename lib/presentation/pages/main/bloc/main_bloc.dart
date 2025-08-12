import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/user.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    on<SetErrorEvent>(_onSetErrorEvent);
    on<GetUserEvent>(_onGetUserEvent);
    on<GoToPageEvent>(_onGoToPageEvent);
    on<UpdateCaloriesEvent>(_onUpdateCaloriesEvent);
    on<AddFoodProductEvent>(_onAddFoodProductEvent);
    on<RemoveFoodProductEvent>(_onRemoveFoodProductEvent);
    on<LoadFoodProductsEvent>(_onLoadFoodProductsEvent);
  }

  /// переход на страницу
  void _onGoToPageEvent(GoToPageEvent event, Emitter<MainState> emit) {
    emit(state.copyWith(selectedIndex: event.pageIndex));
  }

  /// получение пользователя
  Future<void> _onGetUserEvent(
    GetUserEvent event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.getUser();
    emit(state.copyWith(isLoading: false));
    if (answer.isEmpty) {
      emit(state.copyWith(user: repo.user));
    } else {
      emit(state.copyWith(error: answer));
    }
  }

  /// установка ошибки
  void _onSetErrorEvent(SetErrorEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(error: event.error));
  }

  /// НОВОЕ: обновление данных о калориях
  void _onUpdateCaloriesEvent(
    UpdateCaloriesEvent event,
    Emitter<MainState> emit,
  ) {
    emit(
      state.copyWith(
        consumedCalories: event.consumedCalories,
        burnedCalories: event.burnedCalories,
        maxCalories: event.maxCalories,
      ),
    );
  }

  /// Получить отфильтрованные продукты по типу приема пищи
  List<FoodProduct> getFilteredProducts(String mealType, String searchQuery) {
    final products = state.foodProducts.where((product) => 
      product.mealType == mealType
    ).toList();
    
    if (searchQuery.isEmpty) return products;
    
    return products.where((product) => 
      product.name.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  /// НОВОЕ: добавление продукта питания
  Future<void> _onAddFoodProductEvent(AddFoodProductEvent event, Emitter<MainState> emit) async {
    try {
      final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
      await dailyCaloriesRepo.addFoodProduct(event.product);
      
      // Обновляем состояние
      final todayRecord = await dailyCaloriesRepo.getOrCreateTodayRecord();
      emit(state.copyWith(
        consumedCalories: todayRecord.consumedCalories,
        foodProducts: dailyCaloriesRepo.foodProducts,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Ошибка добавления продукта: $e'));
    }
  }

  /// НОВОЕ: удаление продукта питания
  Future<void> _onRemoveFoodProductEvent(RemoveFoodProductEvent event, Emitter<MainState> emit) async {
    try {
      final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
      await dailyCaloriesRepo.removeFoodProduct(event.productId);
      
      // Обновляем состояние
      final todayRecord = await dailyCaloriesRepo.getOrCreateTodayRecord();
      emit(state.copyWith(
        consumedCalories: todayRecord.consumedCalories,
        foodProducts: dailyCaloriesRepo.foodProducts,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Ошибка удаления продукта: $e'));
    }
  }

  /// НОВОЕ: загрузка продуктов питания
  Future<void> _onLoadFoodProductsEvent(LoadFoodProductsEvent event, Emitter<MainState> emit) async {
    try {
      final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
      emit(state.copyWith(foodProducts: dailyCaloriesRepo.foodProducts));
    } catch (e) {
      emit(state.copyWith(error: 'Ошибка загрузки продуктов: $e'));
    }
  }
}
