import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

class ProductListItem extends StatelessWidget {
  final FoodProduct product;
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;

  const ProductListItem({
    super.key,
    required this.product,
    this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                          child: const Icon(Icons.fastfood, color: Colors.grey),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    );
  }
}
