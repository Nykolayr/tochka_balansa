import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/presentation/pages/food/eat_page.dart';

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
    final currentFavorite = [...state.favoriteProducts];
  }

  // Переключаем табы
  void _onChangeTab(ChangeTab event, Emitter<FoodState> emit) {
    emit(
      state.copyWith(
        currentTab: event.tab,
        searchProducts: Get.find<FoodProductRepository>().getProducts(),
      ),
    );
  }

  // Добавить продукт в обед
  void _onAddToLunch(AddProductToLunch event, Emitter<FoodState> emit) {
    final currentLunch = [...state.lunchProducts];

    // Добавляем с текущим временем
    final productWithTime = event.product.copyWith(timestamp: DateTime.now());

    currentLunch.add(productWithTime);

    emit(state.copyWith(lunchProducts: currentLunch, isListChange: true));
  }

  // Добавить продукт в ужин
  void _onAddToDinner(AddProductToDinner event, Emitter<FoodState> emit) {
    final currentDinner = [...state.dinnerProducts];
  }

  // Добавить продукт в завтрак
  void _onAddToBreakfast(AddProductToBreakfast event, Emitter<FoodState> emit) {
    final currentBreakfast = [...state.breakfastProducts];

    // Добавляем с текущим временем
    final productWithTime = event.product.copyWith(timestamp: DateTime.now());

    currentBreakfast.add(productWithTime);

    emit(
      state.copyWith(breakfastProducts: currentBreakfast, isListChange: true),
    );
  }

  // Добавить продукт в перекус
  void _onAddToSnack(AddProductToSnack event, Emitter<FoodState> emit) {
    final currentSnack = [...state.snackProducts];
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

  // Добавить/обновить в частые
  void _onAddToFrequent(AddProductToFrequent event, Emitter<FoodState> emit) {
    final currentFrequent = [...state.frequentProducts];

    // Ищем продукт по ID
    final existingIndex = currentFrequent.indexWhere(
      (p) => p.id == event.product.id,
    );

    // Увеличиваем счетчик использования
    final productUpdated = event.product.copyWith(timestamp: DateTime.now());

    if (existingIndex >= 0) {
      // Обновляем существующий
      currentFrequent[existingIndex] = productUpdated;
    } else {
      // Добавляем новый
      currentFrequent.add(productUpdated);
    }

    // Сортируем по времени добавления (последние сверху)
    currentFrequent.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    emit(state.copyWith(frequentProducts: currentFrequent, isListChange: true));
  }

  // Обновить список для поиска
  void _onUpdateSearchProducts(
    UpdateSearchProducts event,
    Emitter<FoodState> emit,
  ) {
    emit(state.copyWith(searchProducts: event.products));
  }

  // Удобный метод: добавить продукт во все категории
  void addProductToAllCategories(FoodProduct product) {
    add(AddProductToBreakfast(product));
    add(AddProductToRecent(product));
    add(AddProductToFrequent(product));
  }
}
