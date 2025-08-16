import 'package:flutter/material.dart';
import 'package:tochka_balansa/data/models/food/food_product.dart';

class AddProductForm extends StatefulWidget {
  final String barcode;
  final Function(FoodProduct) onSave;

  const AddProductForm({
    super.key,
    required this.barcode,
    required this.onSave,
  });

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _fiberController = TextEditingController();
  final _saturatedFatController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _unitController.text = 'г'; // По умолчанию граммы
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbohydratesController.dispose();
    _fiberController.dispose();
    _saturatedFatController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = FoodProduct.create(
        name: _nameController.text.trim(),
        barcode: widget.barcode,
        amount: double.tryParse(_amountController.text) ?? 100.0,
        unit: _unitController.text.trim(),
        caloriesPer100: int.tryParse(_caloriesController.text) ?? 0,
        proteinsPer100: double.tryParse(_proteinsController.text),
        fatPer100: double.tryParse(_fatsController.text),
        carbsPer100: double.tryParse(_carbohydratesController.text),
        fiberPer100: double.tryParse(_fiberController.text),
        saturatedFatPer100: double.tryParse(_saturatedFatController.text),
      );

      widget.onSave(product);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информационный блок
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Новый продукт',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Баркод: ${widget.barcode}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Заполните информацию о продукте для добавления в локальную базу данных.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Название (обязательное)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название продукта *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название продукта';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 16),

            // Количество и единица измерения
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Количество',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '100',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Единица',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Калории (обязательное)
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Калории на 100г *',
                border: OutlineInputBorder(),
                suffixText: 'ккал',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите калории';
                }
                if (int.tryParse(value) == null) {
                  return 'Введите число';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Питательные вещества
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinsController,
                    decoration: const InputDecoration(
                      labelText: 'Белки',
                      border: OutlineInputBorder(),
                      suffixText: 'г',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fatsController,
                    decoration: const InputDecoration(
                      labelText: 'Жиры',
                      border: OutlineInputBorder(),
                      suffixText: 'г',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbohydratesController,
                    decoration: const InputDecoration(
                      labelText: 'Углеводы',
                      border: OutlineInputBorder(),
                      suffixText: 'г',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fiberController,
                    decoration: const InputDecoration(
                      labelText: 'Клетчатка',
                      border: OutlineInputBorder(),
                      suffixText: 'г',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _saturatedFatController,
              decoration: const InputDecoration(
                labelText: 'Насыщенные жиры',
                border: OutlineInputBorder(),
                suffixText: 'г',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Кнопка сохранения
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Сохранить продукт',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Информация о сохранении
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Продукт будет сохранен в локальную базу данных и будет доступен при следующем сканировании.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
