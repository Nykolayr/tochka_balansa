import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';

enum EatType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get title {
    switch (this) {
      case EatType.breakfast:
        return 'Завтрак';
      case EatType.lunch:
        return 'Обед';
      case EatType.dinner:
        return 'Ужин';
      case EatType.snack:
        return 'Перекус';
    }
  }

  /// Добавляем продукт через bloc
  Function(FoodProduct) get addProductBloc {
    switch (this) {
      case EatType.breakfast:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToBreakfast(product));
        };

      case EatType.lunch:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToLunch(product));
        };

      case EatType.dinner:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToDinner(product));
        };

      case EatType.snack:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToSnack(product));
        };
    }
  }

  Color get color {
    switch (this) {
      case EatType.breakfast:
        return Colors.orange;
      case EatType.lunch:
        return Colors.green;
      case EatType.dinner:
        return Colors.blue;
      case EatType.snack:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case EatType.breakfast:
        return Icons.wb_sunny;
      case EatType.lunch:
        return Icons.restaurant;
      case EatType.dinner:
        return Icons.nights_stay;
      case EatType.snack:
        return Icons.coffee;
    }
  }
}
