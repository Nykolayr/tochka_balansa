import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/repositories/food_product_repository.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';

class EatPage extends StatefulWidget {
  final EatType eatType;
  const EatPage({super.key, required this.eatType});

  @override
  State<EatPage> createState() => _EatPageState();
}

class _EatPageState extends State<EatPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  late TabController _tabController;

  // Текущий выбранный таб
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });
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
        title: textLang(widget.eatType.title),
        isBack: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/main/home/add-product', extra: widget.eatType);
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
      bottomNavigationBar: _buildBreakfastBlock(),
    );
  }

  Widget _buildProductsList(ProductTabType tabType) {
    // Получаем продукты по типу таба
    final products = tabType.products;

    if (products.isEmpty) {
      return Center(
        child: Text(
          'Нет продуктов в ${tabType.title}',
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
            // НОВОЕ: звездочка избранного в начале
            leading: IconButton(
              onPressed: () {
                Get.find<FoodBloc>().add(AddProductToFavorite(product));
              },
              icon: Icon(
                product.isFavorite ? Icons.star : Icons.star_border,
                color: product.isFavorite ? Colors.amber : Colors.grey,
                size: 24,
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
                  onPressed: () {
                    // TODO: добавить продукт в завтрак
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

  Widget _buildBreakfastBlock() {
    // TODO: получать текущий завтрак
    final breakfastProducts = <FoodProduct>[];

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
              const Icon(Icons.wb_sunny, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Завтрак',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (breakfastProducts.isNotEmpty)
                Text(
                  '${breakfastProducts.fold<int>(0, (sum, p) => sum + p.totalCalories)} ккал',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (breakfastProducts.isEmpty)
            const Text(
              'Добавьте продукты из списка или добавьте продукт через кнопку +',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            )
          else
            Column(
              children: breakfastProducts
                  .map((product) => _buildBreakfastProductItem(product))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBreakfastProductItem(FoodProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.darkBlue,
        borderRadius: BorderRadius.circular(8),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  product.displayAmount,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // TODO: удалить продукт из завтрака
            },
            icon: const Icon(Icons.remove_circle, color: Colors.red),
          ),
        ],
      ),
    );
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
