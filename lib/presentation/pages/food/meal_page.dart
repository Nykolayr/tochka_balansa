import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';

class MealPage extends StatefulWidget {
  final MealType mealType;

  const MealPage({super.key, required this.mealType});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Загружаем продукты при инициализации
    Get.find<MainBloc>().add(LoadFoodProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: widget.mealType.title, isBack: true),
      body: BlocBuilder<MainBloc, MainState>(
        bloc: Get.find<MainBloc>(),
        builder: (context, state) {
          return Column(
            children: [
              // Поиск и кнопка +
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
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
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: показать диалог добавления продукта
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              // Список продуктов
              Expanded(child: _buildProductsList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsList(MainState state) {
    final dailyCaloriesRepo = Get.find<DailyCaloriesRepository>();
    final products = dailyCaloriesRepo.getFilteredProducts(
      widget.mealType.value,
      _searchQuery,
    );

    if (products.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? textLang('Нет добавленных продуктов')
              : textLang('Продукты не найдены'),
          style: TextStyle(
            fontSize: 16,
            color: AppColor.greyText.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${product.displayAmount} • ${product.displayCalories}',
              style: TextStyle(color: AppColor.greyText.withValues(alpha: 0.7)),
            ),
            trailing: IconButton(
              onPressed: () {
                // TODO: показать диалог редактирования/удаления
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        );
      },
    );
  }
}
