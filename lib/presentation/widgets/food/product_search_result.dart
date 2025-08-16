import 'package:flutter/material.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/data/services/product_service.dart';
import 'package:tochka_balansa/presentation/widgets/common/custom_modal_sheet.dart';
import 'package:tochka_balansa/presentation/widgets/food/add_product_form.dart';

class ProductSearchResultWidget extends StatelessWidget {
  final ProductSearchResult result;
  final Function(FoodProduct) onProductSelected;
  final VoidCallback? onRetry;

  const ProductSearchResultWidget({
    super.key,
    required this.result,
    required this.onProductSelected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (result.status) {
      case ProductSearchStatus.foundLocal:
        return _buildLocalProductCard(context, result.localProduct!);
      case ProductSearchStatus.foundApi:
        return _buildApiProductCard(context, result.apiProduct!);
      case ProductSearchStatus.notFound:
        return _buildNotFoundCard(context, result.barcode!);
      case ProductSearchStatus.error:
        return _buildErrorCard(context, result.error!);
    }
  }

  Widget _buildLocalProductCard(BuildContext context, FoodProduct product) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Найден в локальной базе',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            if (product.barcode != null) ...[
              const SizedBox(height: 8),
              Text(
                'Баркод: ${product.barcode}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${product.caloriesPer100} ккал на 100${product.unit}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onProductSelected(product),
                child: const Text('Добавить в прием пищи'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiProductCard(BuildContext context, FoodProduct product) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Найден в OpenFoodFacts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            if (product.barcode != null) ...[
              const SizedBox(height: 8),
              Text(
                'Баркод: ${product.barcode}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${product.caloriesPer100} ккал на 100${product.unit}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onProductSelected(product),
                    child: const Text('Добавить в прием пищи'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showSaveToLocalDialog(context, product),
                  child: const Text('Сохранить локально'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundCard(BuildContext context, String barcode) {
    // Автоматически показываем форму добавления продукта
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddProductForm(context, barcode);
    });

    // Возвращаем информационную карточку
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Добавить новый продукт',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Баркод: $barcode',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Продукт не найден. Заполните информацию о продукте ниже.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Повторить поиск'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ошибка поиска',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Произошла ошибка при поиске продукта:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Повторить'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSaveToLocalDialog(BuildContext context, FoodProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сохранить продукт'),
        content: Text(
          'Сохранить продукт "${product.name}" в локальную базу данных?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Здесь можно добавить логику сохранения
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showAddProductForm(BuildContext context, String barcode) {
    CustomModalSheet.show(
      context: context,
      title: 'Добавить новый продукт',
      height: MediaQuery.of(context).size.height * 0.9, // Увеличиваем высоту
      child: AddProductForm(
        barcode: barcode,
        onSave: (product) async {
          try {
            // Сохраняем продукт в локальную БД
            // Здесь нужно передать ProductService для сохранения
            // await _productService.saveLocalProduct(product);

            // Показываем уведомление об успехе
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Продукт "${product.name}" успешно добавлен!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 3),
              ),
            );

            // Закрываем модалку
            Navigator.of(context).pop();

            // Обновляем результат поиска
            if (onRetry != null) {
              onRetry!();
            }
          } catch (e) {
            // Показываем ошибку
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка при сохранении: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
      ),
    );
  }
}
