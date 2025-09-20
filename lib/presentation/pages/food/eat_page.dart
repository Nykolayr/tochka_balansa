import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/repositories/food_product_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_events_repository.dart';
import 'package:tochka_balansa/data/models/health/daily_event.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class EatPage extends StatefulWidget {
  final EatType? initialEatType; // Опциональный начальный тип
  const EatPage({super.key, this.initialEatType});

  @override
  State<EatPage> createState() => _EatPageState();
}

class _EatPageState extends State<EatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  late TabController _tabController;

  // Текущий выбранный таб
  int currentTabIndex = 0;

  // Текущий тип приема пищи
  late EatType currentEatType;

  // Защита от повторных нажатий
  bool _isAddingProduct = false;
  bool _isRemovingProduct = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });

    // Инициализируем текущий тип приема пищи
    currentEatType = widget.initialEatType ?? EatType.breakfast;

    // Очищаем все категории при входе на страницу
    _clearAllMealCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: textLang(currentEatType.title),
        isBack: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/main/home/add-product', extra: currentEatType);
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.darkBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
      body: BlocBuilder<FoodBloc, FoodState>(
        bloc: Get.find<FoodBloc>(),
        builder: (context, state) {
          return Column(
            children: [
              // Поиск
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: textLang('Поиск продуктов...'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              // Табы
              TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                labelColor: AppColor.green,
                unselectedLabelColor: Colors.black,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 2.0, color: AppColor.green),
                  ),
                ),
                tabs: ProductTabType.values
                    .map((e) => Tab(text: textLang(e.title)))
                    .toList(),
              ),

              const Gap(16),
              // Список продуктов по табам
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsList(ProductTabType.frequent),
                    _buildProductsList(ProductTabType.recent),
                    _buildProductsList(ProductTabType.favorite),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BlocBuilder<MainBloc, MainState>(
        bloc: Get.find<MainBloc>(),
        builder: (context, mainState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Блок с продуктами
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.33, // Максимум 1/3 экрана
                ),
                child: _buildBreakfastBlock(),
              ),
              // Переключатель типов приема пищи (сплошная полоса) - в самом низу
              _buildEatTypeSelector(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsList(ProductTabType tabType) {
    // Получаем продукты по типу таба
    final products = tabType.products;

    // Фильтруем продукты по поисковому запросу
    final filteredProducts = searchQuery.isEmpty
        ? products
        : products
              .where(
                (product) => product.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isEmpty
              ? 'Нет продуктов в ${tabType.title}'
              : 'Продукты не найдены',
          style: TextStyle(
            fontSize: 16,
            color: AppColor.greyText.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            // НОВОЕ: звездочка избранного в начале
            leading: GestureDetector(
              onTap: () {
                Get.find<FoodBloc>().add(AddProductToFavorite(product));
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  product.isFavorite ? Icons.star : Icons.star_border,
                  color: product.isFavorite ? Colors.amber : Colors.grey,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              product.displayAmount,
              style: TextStyle(color: AppColor.greyText.withValues(alpha: 0.7)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.displayCalories,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isAddingProduct
                      ? null
                      : () async {
                          if (_isAddingProduct) return;

                          setState(() {
                            _isAddingProduct = true;
                          });

                          try {
                            // Добавляем продукт в соответствующий прием пищи
                            switch (currentEatType) {
                              case EatType.breakfast:
                                Get.find<FoodBloc>().add(
                                  AddProductToBreakfast(product),
                                );
                                break;
                              case EatType.lunch:
                                Get.find<FoodBloc>().add(
                                  AddProductToLunch(product),
                                );
                                break;
                              case EatType.dinner:
                                Get.find<FoodBloc>().add(
                                  AddProductToDinner(product),
                                );
                                break;
                              case EatType.snack:
                                Get.find<FoodBloc>().add(
                                  AddProductToSnack(product),
                                );
                                break;
                            }

                            // Также добавляем в недавние для истории
                            Get.find<FoodBloc>().add(
                              AddProductToRecent(product),
                            );

                            // Принудительно обновляем UI
                            setState(() {});

                            // Обновляем MainBloc с новыми калориями
                            final dailyCaloriesRepo =
                                Get.find<DailyCaloriesRepository>();
                            final updatedRecord = dailyCaloriesRepo
                                .getCurrentRecord();
                            final mainBloc = Get.find<MainBloc>();
                            mainBloc.add(
                              UpdateCaloriesEvent(
                                consumedCalories:
                                    updatedRecord.consumedCalories,
                                burnedCalories: updatedRecord.burnedCalories,
                                maxCalories: updatedRecord.maxCalories,
                              ),
                            );

                            // Показываем уведомление об успехе
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Продукт "${product.name}" добавлен в ${currentEatType.title}',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } finally {
                            setState(() {
                              _isAddingProduct = false;
                            });
                          }
                        },
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColor.darkBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Виджет переключения типов приема пищи
  Widget _buildEatTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Row(
        children: EatType.values.map((eatType) {
          final isSelected = currentEatType == eatType;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentEatType = eatType;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.darkBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  eatType.icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreakfastBlock() {
    // Получаем продукты из репозитория
    final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
    final currentRecord = dailyCaloriesRepo.getCurrentRecord();

    List<FoodProduct> mealProducts = [];
    switch (currentEatType) {
      case EatType.breakfast:
        mealProducts = currentRecord.breakfast;
        break;
      case EatType.lunch:
        mealProducts = currentRecord.lunch;
        break;
      case EatType.dinner:
        mealProducts = currentRecord.dinner;
        break;
      case EatType.snack:
        mealProducts = currentRecord.snacks;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.darkBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(currentEatType.icon, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                currentEatType.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (mealProducts.isNotEmpty)
                Text(
                  '${mealProducts.fold<int>(0, (sum, p) => sum + p.totalCalories)} ккал',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (mealProducts.isEmpty)
            Text(
              'Добавьте продукты из списка или добавьте продукт через кнопку +',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mealProducts.length,
                itemBuilder: (context, index) {
                  final product = mealProducts[index];
                  return _buildMealProductItem(product, index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealProductItem(FoodProduct product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.darkBlue, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkBlue,
                  ),
                ),
                Text(
                  product.displayAmount,
                  style: TextStyle(
                    color: AppColor.greyText.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            product.displayCalories,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isRemovingProduct
                ? null
                : () async {
                    if (_isRemovingProduct) return;

                    setState(() {
                      _isRemovingProduct = true;
                    });

                    try {
                      // Удаляем продукт из соответствующего приема пищи по индексу
                      final dailyCaloriesRepo =
                          Get.find<DailyCaloriesRepository>();
                      await dailyCaloriesRepo.removeFoodProductByIndex(
                        index,
                        currentEatType,
                      );

                      // Принудительно обновляем UI
                      setState(() {});

                      // Обновляем MainBloc с новыми калориями
                      final updatedRecord = dailyCaloriesRepo
                          .getCurrentRecord();
                      final mainBloc = Get.find<MainBloc>();
                      mainBloc.add(
                        UpdateCaloriesEvent(
                          consumedCalories: updatedRecord.consumedCalories,
                          burnedCalories: updatedRecord.burnedCalories,
                          maxCalories: updatedRecord.maxCalories,
                        ),
                      );

                      // Показываем уведомление
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Продукт "${product.name}" удален из ${currentEatType.title}',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } finally {
                      setState(() {
                        _isRemovingProduct = false;
                      });
                    }
                  },
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Плавающая кнопка для создания записи
  Widget _buildFloatingActionButton() {
    return BlocBuilder<MainBloc, MainState>(
      bloc: Get.find<MainBloc>(),
      builder: (context, mainState) {
        // Получаем продукты для текущего типа приема пищи
        final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
        final currentRecord = dailyCaloriesRepo.getCurrentRecord();

        List<FoodProduct> mealProducts = [];
        switch (currentEatType) {
          case EatType.breakfast:
            mealProducts = currentRecord.breakfast;
            break;
          case EatType.lunch:
            mealProducts = currentRecord.lunch;
            break;
          case EatType.dinner:
            mealProducts = currentRecord.dinner;
            break;
          case EatType.snack:
            mealProducts = currentRecord.snacks;
            break;
        }

        // Показываем кнопку только если есть продукты
        if (mealProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: _createMealRecord,
          backgroundColor: AppColor.darkBlue,
          foregroundColor: Colors.white,
          icon: Icon(currentEatType.icon),
          label: Text('Добавить ${currentEatType.title}'),
        );
      },
    );
  }

  /// Создать запись приема пищи
  Future<void> _createMealRecord() async {
    try {
      final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
      final eventsRepo = Get.find<DailyEventsRepository>();
      final currentRecord = dailyCaloriesRepo.getCurrentRecord();

      // Получаем продукты для текущего типа приема пищи
      List<FoodProduct> mealProducts = [];
      switch (currentEatType) {
        case EatType.breakfast:
          mealProducts = currentRecord.breakfast;
          break;
        case EatType.lunch:
          mealProducts = currentRecord.lunch;
          break;
        case EatType.dinner:
          mealProducts = currentRecord.dinner;
          break;
        case EatType.snack:
          mealProducts = currentRecord.snacks;
          break;
      }

      if (mealProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет продуктов для добавления'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Преобразуем EatType в EventType
      EventType eventType;
      switch (currentEatType) {
        case EatType.breakfast:
          eventType = EventType.breakfast;
          break;
        case EatType.lunch:
          eventType = EventType.lunch;
          break;
        case EatType.dinner:
          eventType = EventType.dinner;
          break;
        case EatType.snack:
          eventType = EventType.snacks;
          break;
      }

      // Рассчитываем общие калории и вес
      final totalCalories = mealProducts.fold<int>(
        0,
        (sum, p) => sum + p.totalCalories,
      );
      final totalWeight = mealProducts.fold<int>(
        0,
        (sum, p) => sum + p.amount.toInt(),
      );
      final productNames = mealProducts.map((p) => p.name).toList();

      // Создаем событие потребления
      await eventsRepo.addConsumedEvent(
        type: eventType,
        products: productNames,
        totalWeight: totalWeight,
        calories: totalCalories,
        note: null,
      );

      // Очищаем все категории приемов пищи
      await _clearAllMealCategories();

      // Показываем уведомление об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${currentEatType.title} добавлен! ${totalCalories} ккал',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Возвращаемся назад
      Navigator.of(context).pop();
    } catch (e) {
      print('Ошибка создания записи приема пищи: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Очистить все категории приемов пищи
  Future<void> _clearAllMealCategories() async {
    try {
      final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();

      // Очищаем все категории
      await dailyCaloriesRepo.clearBreakfast();
      await dailyCaloriesRepo.clearLunch();
      await dailyCaloriesRepo.clearDinner();
      await dailyCaloriesRepo.clearSnacks();

      // Обновляем UI
      setState(() {});
    } catch (e) {
      print('Ошибка очистки категорий: $e');
    }
  }
}

/// Типы табов для продуктов
enum ProductTabType {
  frequent, // Частые
  recent, // Недавние
  favorite; // Избранные

  String get title => switch (this) {
    frequent => 'ЧАСТЫЕ',
    recent => 'НЕДАВНИЕ',
    favorite => 'ИЗБРАННЫЕ',
  };

  List<FoodProduct> get products {
    FoodProductRepository repo = Get.find<FoodProductRepository>();
    switch (this) {
      case ProductTabType.favorite:
        return repo.getFavoriteProducts();
      case ProductTabType.frequent:
        return repo.getFrequentProducts();
      case ProductTabType.recent:
        return repo.getRecentProducts();
    }
  }
}
