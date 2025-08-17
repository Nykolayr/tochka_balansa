import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/data/repositories/food_product_repository.dart';
import 'package:tochka_balansa/presentation/pages/food/eat_page.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  FoodBloc() : super(FoodState.initial()) {
    // Обработчики событий
    on<AddProductToBreakfast>(_onAddToBreakfast);
    on<AddProductToLunch>(_onAddToLunch);
    on<AddProductToDinner>(_onAddToDinner);
    on<AddProductToSnack>(_onAddToSnack);
    on<AddProductToRecent>(_onAddToRecent);
    on<AddProductToFavorite>(_onAddToFavorite);
    on<ChangeTab>(_onChangeTab);
  }

  // Добавить продукт в избранное
  void _onAddToFavorite(AddProductToFavorite event, Emitter<FoodState> emit) {
    FoodProductRepository repo = Get.find<FoodProductRepository>();
    repo.toggleProductFavorite(event.product.id);
    emit(state.copyWith(favoriteProducts: repo.getFavoriteProducts()));
  }

  // Переключаем табы
  void _onChangeTab(ChangeTab event, Emitter<FoodState> emit) {
    emit(
      state.copyWith(currentTab: event.tab, searchProducts: event.tab.products),
    );
  }

  // Добавить продукт в обед
  void _onAddToLunch(AddProductToLunch event, Emitter<FoodState> emit) {
    DailyCaloriesRepository repo = Get.find<DailyCaloriesRepository>();
    repo.addFoodProduct(event.product, EatType.lunch);
    emit(state.copyWith(lunchProducts: repo.getCurrentRecord().lunch));
  }

  // Добавить продукт в ужин
  void _onAddToDinner(AddProductToDinner event, Emitter<FoodState> emit) {
    DailyCaloriesRepository repo = Get.find<DailyCaloriesRepository>();
    repo.addFoodProduct(event.product, EatType.dinner);
    emit(state.copyWith(lunchProducts: repo.getCurrentRecord().dinner));
  }

  // Добавить продукт в завтрак
  void _onAddToBreakfast(AddProductToBreakfast event, Emitter<FoodState> emit) {
    DailyCaloriesRepository repo = Get.find<DailyCaloriesRepository>();
    repo.addFoodProduct(event.product, EatType.breakfast);
    emit(state.copyWith(lunchProducts: repo.getCurrentRecord().breakfast));
  }

  // Добавить продукт в перекус
  void _onAddToSnack(AddProductToSnack event, Emitter<FoodState> emit) {
    DailyCaloriesRepository repo = Get.find<DailyCaloriesRepository>();
    repo.addFoodProduct(event.product, EatType.snack);
    emit(state.copyWith(lunchProducts: repo.getCurrentRecord().snacks));
  }

  // Добавить продукт в недавние
  void _onAddToRecent(AddProductToRecent event, Emitter<FoodState> emit) {
    // Удаляем дубликаты, оставляем самые последние
    final currentRecent = state.recentProducts
        .where((p) => p.id != event.product.id)
        .take(19)
        .toList();

    // Добавляем новый продукт в начало
    currentRecent.add(event.product);

    emit(
      state.copyWith(
        recentProducts: currentRecent.toList(),
        isListChange: true,
      ),
    );
  }
}
