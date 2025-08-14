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
    // TODO: Показать диалог для ручного ввода
    Logger.d('Показываем диалог для ручного ввода штрих-кода: $barcode');
  }
}
