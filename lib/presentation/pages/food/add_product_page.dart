import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/food_api_service.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/app_bar_widget.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodApiProduct> _searchResults = [];
  bool _isSearching = false;
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBarWidget(title: 'Добавить продукт', showBackButton: true),
      body: Column(
        children: [
          // Поиск и сканер
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск продуктов...',
                      hintStyle: const TextStyle(color: AppColor.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColor.grey,
                      ),
                      filled: true,
                      fillColor: AppColor.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.greyLine),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _scanBarcode,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: AppColor.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Результаты поиска
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: AppColor.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Введите название продукта или отсканируйте штрих-код',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.greyText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.greyLine),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColor.grey,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fastfood,
                                          color: AppColor.white,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColor.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.fastfood,
                                    color: AppColor.white,
                                  ),
                                ),
                          title: Text(
                            product.displayName,
                            style: const TextStyle(
                              color: AppColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.brand != null)
                                Text(
                                  product.brand!,
                                  style: const TextStyle(
                                    color: AppColor.greyText,
                                    fontSize: 14,
                                  ),
                                ),
                              if (product.calories > 0)
                                Text(
                                  '${product.calories} ккал на 100г',
                                  style: const TextStyle(
                                    color: AppColor.greyText,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => _selectProduct(product),
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColor.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColor.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Поиск продуктов при вводе
  Future<void> _onSearchChanged(String query) async {
    setState(() {
      searchQuery = query;
    });

    if (query.length < 2) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await FoodApiService.searchProducts(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Сканирование штрих-кода
  Future<void> _scanBarcode() async {
    // TODO: Интеграция со сканером штрих-кода
    // Пока что просто показываем сообщение
    Get.snackbar(
      'Сканер',
      'Функция сканирования будет добавлена позже',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Выбор продукта
  void _selectProduct(FoodApiProduct apiProduct) {
    _showProductDetailsModal(apiProduct);
  }

  /// Показать модальное окно с деталями продукта
  void _showProductDetailsModal(FoodApiProduct apiProduct) {
    double amount = 100.0;
    String unit = 'г';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                if (apiProduct.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      apiProduct.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColor.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fastfood,
                            color: AppColor.white,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apiProduct.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColor.black,
                        ),
                      ),
                      if (apiProduct.brand != null)
                        Text(
                          apiProduct.brand!,
                          style: const TextStyle(
                            color: AppColor.greyText,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Информация о продукте
            if (apiProduct.calories > 0)
              _buildInfoRow('Калории', '${apiProduct.calories} ккал на 100г'),
            if (apiProduct.proteinsPer100g != null)
              _buildInfoRow(
                'Белки',
                '${apiProduct.proteinsPer100g!.toStringAsFixed(1)}г на 100г',
              ),
            if (apiProduct.fatsPer100g != null)
              _buildInfoRow(
                'Жиры',
                '${apiProduct.fatsPer100g!.toStringAsFixed(1)}г на 100г',
              ),
            if (apiProduct.carbsPer100g != null)
              _buildInfoRow(
                'Углеводы',
                '${apiProduct.carbsPer100g!.toStringAsFixed(1)}г на 100г',
              ),

            const SizedBox(height: 20),

            // Количество
            Text(
              'Количество:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '100',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      amount = double.tryParse(value) ?? 100.0;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: unit,
                  items: const [
                    DropdownMenuItem(value: 'г', child: Text('г')),
                    DropdownMenuItem(value: 'мл', child: Text('мл')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        unit = value;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.grey,
                      foregroundColor: AppColor.white,
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addProduct(apiProduct, amount, unit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                    ),
                    child: const Text('Выбрать'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Построить строку информации
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppColor.greyText, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Добавить продукт
  void _addProduct(FoodApiProduct apiProduct, double amount, String unit) {
    // Создаем FoodProduct
    final foodProduct = FoodProduct.create(
      name: apiProduct.displayName,
      barcode: apiProduct.barcode,
      amount: amount,
      unit: unit,
      caloriesPer100: apiProduct.calories,
    );

    // Добавляем через блок
    Get.find<MainBloc>().add(AddFoodProductEvent(foodProduct));

    // Закрываем модальное окно
    Get.back();

    // Возвращаемся назад
    Get.back();
  }
}
