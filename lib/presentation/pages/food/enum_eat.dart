import 'package:get/get.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';

enum Eat {
  breakfast,
  lunch,
  dinner,
  snack;

  String get title {
    switch (this) {
      case Eat.breakfast:
        return 'Завтрак';
      case Eat.lunch:
        return 'Обед';
      case Eat.dinner:
        return 'Ужин';
      case Eat.snack:
        return 'Перекус';
    }
  }

  Function(FoodProduct) get addProduct {
    switch (this) {
      case Eat.breakfast:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToBreakfast(product));
        };

      case Eat.lunch:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToLunch(product));
        };

      case Eat.dinner:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToDinner(product));
        };

      case Eat.snack:
        return (product) {
          Get.find<FoodBloc>().add(AddProductToSnack(product));
        };
    }
  }
}
