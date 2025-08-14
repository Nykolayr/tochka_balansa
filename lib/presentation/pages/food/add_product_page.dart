import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart'; // Правильный импорт
import 'package:tochka_balansa/data/services/food_api_service.dart';
import 'package:tochka_balansa/presentation/pages/goal/widgets/app_bar_widget.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/scanner/scanner_page.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodProduct> _searchResults = []; // Изменил на FoodProduct
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
      appBar: AppBarWidget(
        title: 'Добавить продукт',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                      return ListTile(
                        leading: product.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.fastfood,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.grey,
                                ),
                              ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${product.caloriesPer100} ккал на 100${product.unit}',
                            ),
                            if (product.proteinsPer100 != null ||
                                product.fatPer100 != null ||
                                product.carbsPer100 != null)
                              Text(
                                'Б: ${product.proteinsPer100?.toStringAsFixed(1) ?? "?"} · '
                                'Ж: ${product.fatPer100?.toStringAsFixed(1) ?? "?"} · '
                                'У: ${product.carbsPer100?.toStringAsFixed(1) ?? "?"} г',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            if (product.totalWeight != null)
                              Text(
                                'Вес упаковки: ${product.totalWeight} ${product.unit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addProductToMeal(product),
                        ),
                        isThreeLine: true,
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
        Logger.d('Тип штрих-кода: ${barcode.runtimeType}');
        Logger.d('Длина штрих-кода: ${barcode.length}');

        await _searchByBarcode(barcode);
      }
    } catch (e) {
      Logger.e('Ошибка сканирования: $e');
    }
  }

  Future<void> _searchByBarcode(String barcode) async {
    try {
      setState(() {
        _isLoading = true;
        _searchResults = [];
      });

      final product = await FoodApiService.getProductByBarcode(barcode);

      if (product != null) {
        setState(() {
          _searchResults = [product];
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });

        // Показываем диалог для ручного ввода
        _showManualInputDialog(barcode);
      }
    } catch (e) {
      Logger.e('Ошибка поиска по штрих-коду: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProducts(String query) async {
    Logger.d('Начинаем поиск: $query');

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

      Logger.d('Вызываем FoodApiService.searchProducts');
      final results = await FoodApiService.searchProducts(query);
      Logger.d('Получили результаты: ${results.length}');

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
    // TODO: Показать диалог для ручного ввода
    Logger.d('Показываем диалог для ручного ввода штрих-кода: $barcode');
  }
}
