import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class ProductListItemWidget extends StatelessWidget {
  final FoodProduct product;
  final VoidCallback? onAddToMeal;

  const ProductListItemWidget({
    super.key,
    required this.product,
    this.onAddToMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.darkBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Звездочка избранного
          GestureDetector(
            onTap: () {
              context.read<MainBloc>().add(
                ToggleProductFavoriteEvent(product.id),
              );
            },
            child: Icon(
              product.isFavorite ? Icons.star : Icons.star_border,
              color: product.isFavorite ? AppColor.yellow : AppColor.grey,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Информация о продукте
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.amount} ${product.unit}',
                  style: const TextStyle(color: AppColor.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          // Калории и кнопка добавления
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.caloriesPer100} ккал',
                style: const TextStyle(
                  color: AppColor.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onAddToMeal,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColor.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
