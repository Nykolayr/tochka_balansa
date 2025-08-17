// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/food_api_service.dart';
import 'package:tochka_balansa/data/repositories/local_product_repository.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';
import 'package:tochka_balansa/presentation/pages/food/enum_eat.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/app_bar_widget.dart';
import 'package:tochka_balansa/presentation/pages/scanner/scanner_page.dart';
import 'package:tochka_balansa/presentation/pages/food/widgets/product_list_item.dart';

class AddProductPage extends StatefulWidget {
  final EatType eatType;
  const AddProductPage({super.key, required this.eatType});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodProduct> _searchResults = [];
  bool _isLoading = false;
  String searchQuery = '';

  // Теперь используем сингл без инициализации
  final LocalProductRepository _localRepository = LocalProductRepository();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Добавить продукт',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddProductModal(''),
            tooltip: 'Добавить продукт вручную',
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка с кнопкой сканирования
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск продуктов...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchProducts('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.darkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    onPressed: _scanBarcode,
                  ),
                ),
              ],
            ),
          ),

          // Индикатор загрузки
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // Результаты поиска
          Expanded(
            child: _searchResults.isEmpty && !_isLoading
                ? const Center(
                    child: Text('Начните поиск или отсканируйте штрих-код'),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ProductListItem(
                        product: product,
                        onAdd: () => _addProductToMeal(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(builder: (context) => const ScannerPage()),
      );

      if (result != null && result['barcode'] != null) {
        final barcode = result['barcode'].toString();
        Logger.d('Сканер вернул результат: $result');
        Logger.d('Получен штрих-код от сканера: $barcode');

        await _searchByBarcode(barcode);
      }
    } catch (e) {
      Logger.e('Ошибка сканирования: $e');
    }
  }

  Future<void> _searchByBarcode(String barcode) async {
    if (!mounted) return;

    Logger.d('Начинаем поиск по штрих-коду: $barcode');

    try {
      setState(() {
        _isLoading = true;
        _searchResults = [];
      });

      // 1. Сначала ищем в локальной БД
      final localProduct = await _localRepository.getProductByBarcode(barcode);
      if (localProduct != null) {
        Logger.d('Продукт найден в локальной БД: ${localProduct.name}');
        setState(() {
          _searchResults = [localProduct];
          _isLoading = false;
        });
        return;
      }

      // 2. Если не найден локально, ищем в API
      final apiProduct = await FoodApiService.getProductByBarcode(barcode);
      Logger.d('Результат поиска в API: ${apiProduct?.name ?? "null"}');

      if (apiProduct != null) {
        Logger.d('Продукт найден в API, добавляем в результаты');
        setState(() {
          _searchResults = [apiProduct];
          _isLoading = false;
        });
      } else {
        Logger.d('Продукт не найден нигде, показываем модалку');
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });

        // Сразу показываем модалку для заполнения
        if (mounted) {
          _showAddProductModal(barcode);
        }
      }
    } catch (e) {
      Logger.e('Ошибка поиска по штрих-коду: $e');
      setState(() {
        _isLoading = false;
      });

      // Показываем сообщение об ошибке
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка поиска продукта: ${e.toString()}'),
            backgroundColor: AppColor.darkBlue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final results = await FoodApiService.searchProducts(query);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e('Ошибка поиска продуктов: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addProductToMeal(FoodProduct product) {
    Logger.i('Добавляем продукт: ${product.toJson()}');
    Get.find<FoodBloc>().add(AddProductToRecent(product));
  }

  void _showAddProductModal(String barcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController caloriesController =
            TextEditingController();
        final TextEditingController weightController = TextEditingController();
        final TextEditingController barcodeController = TextEditingController();

        // Если баркод передан, заполняем поле
        if (barcode.isNotEmpty) {
          barcodeController.text = barcode;
        }

        // Определяем заголовок и подзаголовок
        final bool isFromScanner = barcode.isNotEmpty;
        final String title = isFromScanner
            ? 'Продукт не найден'
            : 'Добавить новый продукт';
        final String subtitle = isFromScanner
            ? 'Штрих-код: $barcode'
            : 'Заполните информацию о продукте';

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Индикатор перетаскивания
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Заголовок
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Форма
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Информационный блок
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isFromScanner
                                    ? 'Заполните информацию о продукте для добавления в локальную базу данных'
                                    : 'Создайте новый продукт и добавьте его в локальную базу данных',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Баркод (только если не передан)
                      if (!isFromScanner) ...[
                        TextField(
                          controller: barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Штрих-код',
                            border: OutlineInputBorder(),
                            hintText: 'Введите штрих-код (необязательно)',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Название продукта
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Название продукта *',
                          border: OutlineInputBorder(),
                          hintText: 'Введите название продукта',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Калории
                      TextField(
                        controller: caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Калории на 100г',
                          border: OutlineInputBorder(),
                          hintText: '0',
                          suffixText: 'ккал',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      // Вес упаковки
                      TextField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: 'Вес упаковки',
                          border: OutlineInputBorder(),
                          hintText: '0',
                          suffixText: 'г',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 32),

                      // Кнопки
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Отмена'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final productName = nameController.text.trim();
                                Logger.d(
                                  'Попытка создать продукт с названием: "$productName"',
                                );

                                if (productName.isNotEmpty) {
                                  Logger.i(
                                    'barcode $barcode ${barcodeController.text}',
                                  );
                                  // Создаем продукт с ручными данными
                                  final manualProduct = FoodProduct.create(
                                    name: productName,
                                    barcode: isFromScanner
                                        ? barcode
                                        : barcodeController.text.trim(),
                                    amount: 100.0,
                                    unit: 'г',
                                    caloriesPer100:
                                        int.tryParse(caloriesController.text) ??
                                        0,
                                    totalWeight: double.tryParse(
                                      weightController.text,
                                    ),
                                  );

                                  Logger.d(
                                    'Создан ручной продукт: ${manualProduct.name}',
                                  );

                                  // Сохраняем в локальную БД
                                  try {
                                    await _localRepository.saveProduct(
                                      manualProduct,
                                    );
                                    Logger.d('Продукт сохранен в локальную БД');

                                    // Показываем уведомление об успехе
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Продукт "${manualProduct.name}" сохранен локально!',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    Logger.e(
                                      'Ошибка сохранения в локальную БД: $e',
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Ошибка сохранения: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                    return; // Не закрываем модалку при ошибке
                                  }

                                  // Добавляем в результаты поиска
                                  setState(() {
                                    _searchResults = [manualProduct];
                                  });

                                  Navigator.of(context).pop();
                                } else {
                                  Logger.d(
                                    'Название продукта пустое, показываем ошибку',
                                  );
                                  // Показываем ошибку, если название пустое
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Введите название продукта',
                                      ),
                                      backgroundColor: AppColor.darkBlue,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Сохранить'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
