import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

class ProductListItem extends StatelessWidget {
  final FoodProduct product;
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;

  const ProductListItem({
    Key? key,
    required this.product,
    this.onAdd,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Изображение продукта
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 16),
              // Информация о продукте
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.caloriesPer100} ккал на 100${product.unit}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (product.proteinsPer100 != null ||
                        product.fatPer100 != null ||
                        product.carbsPer100 != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Б: ${product.proteinsPer100?.toStringAsFixed(1) ?? "?"} · '
                          'Ж: ${product.fatPer100?.toStringAsFixed(1) ?? "?"} · '
                          'У: ${product.carbsPer100?.toStringAsFixed(1) ?? "?"} г',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Кнопка добавления
              if (onAdd != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColor.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: onAdd,
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                  ),
                ),
              // Кнопка удаления
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProductDetailsSheet(product: product, onAdd: onAdd),
    );
  }
}

class ProductDetailsSheet extends StatelessWidget {
  final FoodProduct product;
  final VoidCallback? onAdd;

  const ProductDetailsSheet({Key? key, required this.product, this.onAdd})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Изображение и основная информация
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.barcode != null)
                      Text('Штрих-код: ${product.barcode}'),
                    if (product.totalWeight != null)
                      Text(
                        'Вес упаковки: ${product.totalWeight} ${product.unit}',
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Калории: ${product.caloriesPer100} ккал на 100${product.unit}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Нутриенты
          const Text(
            'Пищевая ценность на 100г:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildNutrientRow('Белки', product.proteinsPer100),
          _buildNutrientRow('Жиры', product.fatPer100),
          if (product.saturatedFatPer100 != null)
            _buildNutrientRow('- насыщенные', product.saturatedFatPer100),
          _buildNutrientRow('Углеводы', product.carbsPer100),
          if (product.fiberPer100 != null)
            _buildNutrientRow('Клетчатка', product.fiberPer100),

          const SizedBox(height: 24),

          // Кнопка добавления
          if (onAdd != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onAdd?.call();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Добавить продукт',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String name, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(
            value != null ? '${value.toStringAsFixed(1)} г' : '—',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
