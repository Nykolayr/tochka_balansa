# 🏷️ Система сканирования баркодов с локальной БД

## 📋 Описание

Система позволяет сканировать баркоды продуктов и искать их в двух источниках:
1. **Локальная база данных** (Hive) - приоритетный поиск
2. **OpenFoodFacts API** - резервный поиск

Если продукт не найден нигде, пользователь может добавить его вручную через форму.

## 🗂️ Структура файлов

```
lib/
├── data/
│   ├── models/food/
│   │   └── food_product.dart          # Модель продукта (уже существует)
│   ├── repositories/
│   │   └── local_product_repository.dart  # Репозиторий для Hive
│   └── services/
│       └── product_service.dart       # Сервис поиска продуктов
├── presentation/
│   └── widgets/
│       ├── common/
│       │   └── custom_modal_sheet.dart    # Универсальная модалка
│       └── food/
│           ├── add_product_form.dart       # Форма добавления продукта
│           ├── product_search_result.dart  # Отображение результатов
│           └── barcode_scanner_example.dart # Пример использования
```

## 🚀 Как использовать

### 1. Инициализация Hive

В `main.dart` добавьте инициализацию Hive:

```dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  
  // Регистрация адаптеров (если нужно)
  // Hive.registerAdapter(FoodProductAdapter());
  
  runApp(const MyApp());
}
```

### 2. Использование в странице

```dart
import 'package:tochka_balansa/data/services/product_service.dart';
import 'package:tochka_balansa/data/repositories/local_product_repository.dart';
import 'package:tochka_balansa/presentation/widgets/food/product_search_result.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final ProductService _productService;
  late final LocalProductRepository _localRepository;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    _localRepository = LocalProductRepository();
    await _localRepository.init();
    _productService = ProductService(localRepository: _localRepository);
  }
  
  Future<void> _searchProduct(String barcode) async {
    final result = await _productService.searchProductByBarcode(barcode);
    
    // Отображение результата
    showModalBottomSheet(
      context: context,
      builder: (context) => ProductSearchResultWidget(
        result: result,
        onProductSelected: (product) {
          // Логика добавления продукта
        },
        onRetry: () => _searchProduct(barcode),
      ),
    );
  }
}
```

### 3. Сканирование баркода

```dart
// Используйте любой пакет для сканирования
// Например: qr_code_scanner, mobile_scanner

void _scanBarcode() async {
  // Получаем баркод от сканера
  final barcode = await scanner.scan();
  
  if (barcode != null) {
    await _searchProduct(barcode);
  }
}
```

## 🔄 Логика работы

1. **Сканирование баркода**
2. **Поиск в локальной БД** (Hive)
   - Если найден → показываем результат
3. **Поиск в OpenFoodFacts**
   - Если найден → показываем результат + кнопка "Сохранить локально"
4. **Продукт не найден**
   - Показываем форму для ручного добавления
5. **Сохранение в локальную БД**
   - При следующем сканировании будет найден в локальной БД

## 📱 Универсальная модалка

`CustomModalSheet` можно использовать для отображения любого контента:

```dart
CustomModalSheet.show(
  context: context,
  title: 'Заголовок',
  child: YourWidget(),
);
```

## 🗄️ Локальная база данных

### Сохранение продукта

```dart
final product = FoodProduct.create(
  name: 'Название продукта',
  barcode: '123456789',
  amount: 100.0,
  unit: 'г',
  caloriesPer100: 250,
  // ... другие поля
);

await _localRepository.saveProduct(product);
```

### Поиск по баркоду

```dart
final product = await _localRepository.getProductByBarcode('123456789');
```

### Получение всех продуктов

```dart
final allProducts = _localRepository.getAllProducts();
```

## 🎯 Преимущества системы

1. **Быстрый поиск** - локальная БД работает мгновенно
2. **Офлайн доступ** - сохраненные продукты доступны без интернета
3. **Гибкость** - можно добавить любой продукт вручную
4. **Единообразие** - все продукты используют одну модель
5. **Масштабируемость** - легко добавить новые источники данных

## 🔧 Настройка

### Добавление новых полей

Если нужно добавить новые поля в `FoodProduct`:

1. Обновите модель
2. Обновите `copyWith` метод
3. Обновите `toJson`/`fromJson` методы
4. Обновите форму `AddProductForm`

### Добавление новых источников данных

В `ProductService.searchProductByBarcode` добавьте новый источник:

```dart
// 3. Поиск в новом источнике
final newSourceProduct = await _newSourceService.search(barcode);
if (newSourceProduct != null) {
  return ProductSearchResult.newSource(newSourceProduct);
}
```

## 🐛 Отладка

### Логирование

Включите логирование в `LocalProductRepository`:

```dart
print('Поиск продукта по баркоду: $barcode');
print('Найдено продуктов: ${products.length}');
```

### Проверка Hive

Убедитесь, что Hive инициализирован:

```dart
print('Hive initialized: ${Hive.isBoxOpen('local_products')}');
```

## 📚 Дополнительные возможности

1. **Синхронизация** - синхронизация локальной БД с сервером
2. **Резервное копирование** - экспорт/импорт данных
3. **Статистика** - анализ использования продуктов
4. **Категории** - группировка продуктов по типам
5. **Избранное** - быстрый доступ к часто используемым продуктам

## 🚨 Важные моменты

1. **Инициализация Hive** должна происходить в `main()`
2. **Регистрация адаптеров** для сложных моделей
3. **Обработка ошибок** при работе с БД
4. **Валидация данных** в форме добавления
5. **Тестирование** на разных устройствах

## 🔗 Связанные пакеты

- `hive` - локальная NoSQL база данных
- `hive_flutter` - Flutter интеграция для Hive
- `openfoodfacts` - API для продуктов питания
- `qr_code_scanner` - сканирование QR-кодов и баркодов
