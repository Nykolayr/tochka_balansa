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

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        final product = result.product!;
        Logger.d('Продукт найден: ${product.productName}');

        // Получаем калории из нутриентов
        int caloriesPer100 = 0;
        if (product.nutriments != null) {
          // Используем правильный метод getValue с правильными параметрами
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
        }

        return FoodProduct.create(
          name: product.productName ?? 'Неизвестно',
          barcode: barcode,
          amount: 100.0,
          unit: 'г',
          caloriesPer100: caloriesPer100,
          imageUrl: product.imageFrontUrl, // Добавляем URL изображения
        );
      } else {
        Logger.d(
          'Продукт не найден в Open Food Facts. Статус: ${result.status}',
        );
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
          // Получаем калории из нутриентов
          int caloriesPer100 = 0;
          if (product.nutriments != null) {
            // Используем правильный метод getValue с правильными параметрами
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
          }

          return FoodProduct.create(
            name: product.productName ?? 'Неизвестно',
            barcode: product.barcode,
            amount: 100.0,
            unit: 'г',
            caloriesPer100: caloriesPer100,
            imageUrl: product.imageFrontUrl, // Добавляем URL изображения
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
