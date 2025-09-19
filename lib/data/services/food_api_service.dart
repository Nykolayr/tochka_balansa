import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import '../models/food/food_product.dart';

class FoodApiService {
  static bool _initialized = false;

  /// Инициализация Open Food Facts
  static void _initialize() {
    if (!_initialized) {
      OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'Tochka Balansa',
        url: 'https://github.com/your-repo',
      );
      OpenFoodAPIConfiguration.globalLanguages = [
        OpenFoodFactsLanguage.RUSSIAN,
        OpenFoodFactsLanguage.ENGLISH,
      ];
      OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.RUSSIA;
      _initialized = true;
      Logger.d('Open Food Facts инициализирован');
    }
  }

  /// Получить продукт по штрих-коду
  static Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      _initialize();
      Logger.d('Ищем продукт по штрих-коду: $barcode');

      final ProductQueryConfiguration configuration = ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.RUSSIAN,
        fields: [ProductField.ALL],
        version: ProductQueryVersion.v3,
      );

      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        configuration,
      );

      Logger.d('API вернул статус: ${result.status}');
      Logger.d(
        'API вернул product: ${result.product != null ? "не null" : "null"}',
      );
      if (result.product != null) {
        Logger.d('productName: ${result.product!.productName}');
        Logger.d('productName == null: ${result.product!.productName == null}');
        Logger.d(
          'productName.isEmpty: ${result.product!.productName?.isEmpty ?? true}',
        );
      }

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null &&
          result.product!.productName != null &&
          result.product!.productName!.isNotEmpty) {
        final product = result.product!;
        Logger.d('Продукт найден: ${product.productName}');

        // Получаем калории и нутриенты
        int caloriesPer100 = 0;
        double? proteinsPer100;
        double? fatPer100;
        double? carbsPer100;
        double? fiberPer100;
        double? saturatedFatPer100;

        if (product.nutriments != null) {
          // Калории
          final energyKcal = product.nutriments!.getValue(
            Nutrient.energyKCal,
            PerSize.oneHundredGrams,
          );
          if (energyKcal != null) {
            caloriesPer100 = energyKcal.round();
          } else {
            // Если нет ккал, пробуем кДж и конвертируем
            final energyKj = product.nutriments!.getValue(
              Nutrient.energyKJ,
              PerSize.oneHundredGrams,
            );
            if (energyKj != null) {
              caloriesPer100 = (energyKj / 4.184)
                  .round(); // примерное преобразование кДж в ккал
            }
          }

          // Нутриенты
          proteinsPer100 = product.nutriments!.getValue(
            Nutrient.proteins,
            PerSize.oneHundredGrams,
          );
          fatPer100 = product.nutriments!.getValue(
            Nutrient.fat,
            PerSize.oneHundredGrams,
          );
          carbsPer100 = product.nutriments!.getValue(
            Nutrient.carbohydrates,
            PerSize.oneHundredGrams,
          );
          fiberPer100 = product.nutriments!.getValue(
            Nutrient.fiber,
            PerSize.oneHundredGrams,
          );
          saturatedFatPer100 = product.nutriments!.getValue(
            Nutrient.saturatedFat,
            PerSize.oneHundredGrams,
          );
        }

        // Получаем единицу измерения и общий вес
        String unit = 'г';
        double? totalWeight;

        if (product.quantity != null) {
          final String quantity = product.quantity!;
          // Парсим строку вида "470г"
          final RegExp regExp = RegExp(r'(\d+\.?\d*)(\D+)');
          final match = regExp.firstMatch(quantity);
          if (match != null) {
            totalWeight = double.tryParse(match.group(1)!);
            unit = match.group(2)!;
          }
        } else if (product.packagingQuantity != null) {
          totalWeight = product.packagingQuantity;
        }

        return FoodProduct.create(
          name: product.productName ?? 'Неизвестно',
          barcode: barcode,
          amount:
              totalWeight ?? 100.0, // Вес упаковки (количество, которое съел)
          unit: unit,
          caloriesPer100: caloriesPer100, // Калории на 100г
          imageUrl:
              product.imageFrontSmallUrl ??
              product.imageFrontUrl, // Предпочитаем small URL
          totalWeight: totalWeight, // Общий вес упаковки
          proteinsPer100: proteinsPer100,
          fatPer100: fatPer100,
          carbsPer100: carbsPer100,
          fiberPer100: fiberPer100,
          saturatedFatPer100: saturatedFatPer100,
        );
      } else {
        Logger.d(
          'Продукт не найден в Open Food Facts. Статус: ${result.status}',
        );
        if (result.status != ProductResultV3.statusSuccess) {
          Logger.d('Причина: API вернул статус ${result.status}');
        }
        if (result.product == null) {
          Logger.d('Причина: product == null');
        } else if (result.product!.productName == null) {
          Logger.d('Причина: product.productName == null');
        } else if (result.product!.productName!.isEmpty) {
          Logger.d('Причина: product.productName пустая строка');
        }
        return null;
      }
    } catch (e) {
      Logger.e('Ошибка поиска по штрих-коду: $e');
      return null;
    }
  }

  /// Поиск продуктов по названию
  static Future<List<FoodProduct>> searchProducts(String query) async {
    try {
      _initialize();
      Logger.d('Ищем продукты по запросу: $query');

      final ProductSearchQueryConfiguration config =
          ProductSearchQueryConfiguration(
            parametersList: [
              SearchTerms(terms: [query]), // Поисковый запрос
              const PageNumber(page: 1), // Пагинация
              const PageSize(size: 10), // Лимит результатов
            ],
            language: OpenFoodFactsLanguage.RUSSIAN, // Язык
            fields: [ProductField.ALL], // Получаем все поля
            version: ProductQueryVersion.v3, // Актуальная версия API
          );

      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        User(userId: '123', password: '123'), // Анонимный пользователь
        config,
      );

      if (result.products != null && result.products!.isNotEmpty) {
        Logger.d('Найдено продуктов: ${result.products!.length}');

        return result.products!.map((product) {
          // Получаем калории и нутриенты
          int caloriesPer100 = 0;
          double? proteinsPer100;
          double? fatPer100;
          double? carbsPer100;
          double? fiberPer100;
          double? saturatedFatPer100;

          if (product.nutriments != null) {
            // Калории
            final energyKcal = product.nutriments!.getValue(
              Nutrient.energyKCal,
              PerSize.oneHundredGrams,
            );
            if (energyKcal != null) {
              caloriesPer100 = energyKcal.round();
            } else {
              // Если нет ккал, пробуем кДж и конвертируем
              final energyKj = product.nutriments!.getValue(
                Nutrient.energyKJ,
                PerSize.oneHundredGrams,
              );
              if (energyKj != null) {
                caloriesPer100 = (energyKj / 4.184)
                    .round(); // примерное преобразование кДж в ккал
              }
            }

            // Нутриенты
            proteinsPer100 = product.nutriments!.getValue(
              Nutrient.proteins,
              PerSize.oneHundredGrams,
            );
            fatPer100 = product.nutriments!.getValue(
              Nutrient.fat,
              PerSize.oneHundredGrams,
            );
            carbsPer100 = product.nutriments!.getValue(
              Nutrient.carbohydrates,
              PerSize.oneHundredGrams,
            );
            fiberPer100 = product.nutriments!.getValue(
              Nutrient.fiber,
              PerSize.oneHundredGrams,
            );
            saturatedFatPer100 = product.nutriments!.getValue(
              Nutrient.saturatedFat,
              PerSize.oneHundredGrams,
            );
          }

          // Получаем единицу измерения и общий вес
          String unit = 'г';
          double? totalWeight;

          if (product.quantity != null) {
            final String quantity = product.quantity!;
            // Парсим строку вида "470г"
            final RegExp regExp = RegExp(r'(\d+\.?\d*)(\D+)');
            final match = regExp.firstMatch(quantity);
            if (match != null) {
              totalWeight = double.tryParse(match.group(1)!);
              unit = match.group(2)!;
            }
          } else if (product.packagingQuantity != null) {
            totalWeight = product.packagingQuantity;
          }

          return FoodProduct.create(
            name: product.productName ?? 'Неизвестно',
            barcode: product.barcode,
            amount:
                totalWeight ?? 100.0, // Вес упаковки (количество, которое съел)
            unit: unit,
            caloriesPer100: caloriesPer100, // Калории на 100г
            imageUrl:
                product.imageFrontSmallUrl ??
                product.imageFrontUrl, // Предпочитаем small URL
            totalWeight: totalWeight, // Общий вес упаковки
            proteinsPer100: proteinsPer100,
            fatPer100: fatPer100,
            carbsPer100: carbsPer100,
            fiberPer100: fiberPer100,
            saturatedFatPer100: saturatedFatPer100,
          );
        }).toList();
      } else {
        Logger.d('Продукты не найдены');
        return [];
      }
    } catch (e) {
      Logger.e('Ошибка поиска продуктов: $e');
      return [];
    }
  }
}
