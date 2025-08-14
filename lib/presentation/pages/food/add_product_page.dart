import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/food_api_service.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/app_bar_widget.dart';
import 'package:tochka_balansa/presentation/pages/scanner/scanner_page.dart';
import 'package:tochka_balansa/presentation/pages/food/widgets/product_list_item.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodProduct> _searchResults = [];
  bool _isLoading = false;
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Добавить продукт', showBackButton: true),
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

      final product = await FoodApiService.getProductByBarcode(barcode);
      Logger.d('Результат поиска: ${product?.name ?? "null"}');

      if (product != null) {
        Logger.d('Продукт найден, добавляем в результаты');
        setState(() {
          _searchResults = [product];
          _isLoading = false;
        });
      } else {
        Logger.d('Продукт не найден, показываем SnackBar');
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });

        // Показываем сообщение, что продукт не найден
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Продукт со штрих-кодом $barcode не найден в базе данных',
              ),
              backgroundColor: AppColor.darkBlue,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Ввести вручную',
                textColor: Colors.white,
                onPressed: () => _showManualInputDialog(barcode),
              ),
            ),
          );
        }

        // Убираем автоматический вызов диалога - теперь он вызывается только по кнопке
        // _showManualInputDialog(barcode);
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
    // TODO: Добавить продукт в прием пищи
    Logger.d('Добавляем продукт: ${product.name}');
  }

  void _showManualInputDialog(String barcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController caloriesController =
            TextEditingController();
        final TextEditingController weightController = TextEditingController();

        return AlertDialog(
          title: const Text('Продукт не найден'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Штрих-код $barcode не найден в базе данных.'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название продукта',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Калории на 100г',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Вес упаковки (г)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final productName = nameController.text.trim();
                Logger.d('Попытка создать продукт с названием: "$productName"');

                if (productName.isNotEmpty) {
                  // Создаем продукт с ручными данными
                  final manualProduct = FoodProduct.create(
                    name: productName,
                    barcode: barcode,
                    amount: 100.0,
                    unit: 'г',
                    caloriesPer100: int.tryParse(caloriesController.text) ?? 0,
                    totalWeight: double.tryParse(weightController.text),
                  );

                  Logger.d('Создан ручной продукт: ${manualProduct.name}');

                  // Добавляем в результаты поиска
                  setState(() {
                    _searchResults = [manualProduct];
                  });

                  Navigator.of(context).pop();
                } else {
                  Logger.d('Название продукта пустое, показываем ошибку');
                  // Показываем ошибку, если название пустое
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Введите название продукта'),
                      backgroundColor: AppColor.darkBlue,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }
}
