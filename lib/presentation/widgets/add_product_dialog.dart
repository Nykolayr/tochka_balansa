// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/services/product_database_service.dart';

class AddProductDialog extends StatefulWidget {
  final String barcode;

  const AddProductDialog({super.key, required this.barcode});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUnit = 'штук';
  bool _isLoading = false;

  final List<String> _units = [
    'штук',
    'таблеток',
    'капсул',
    'мл',
    'грамм',
    'страниц',
    'доз',
    'порций',
    'часов',
    'минут',
  ];

  @override
  void initState() {
    super.initState();
    // Добавляем слушатель для автоматического преобразования первой буквы
    _nameController.addListener(_capitalizeFirstLetter);
  }

  @override
  void dispose() {
    _nameController.removeListener(_capitalizeFirstLetter);
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Функция для преобразования первой буквы в заглавную
  void _capitalizeFirstLetter() {
    final text = _nameController.text;
    if (text.isNotEmpty && text[0] != text[0].toUpperCase()) {
      final capitalizedText = text[0].toUpperCase() + text.substring(1);
      _nameController.value = TextEditingValue(
        text: capitalizedText,
        selection: TextSelection.collapsed(offset: capitalizedText.length),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final product = ProductDatabaseService.createProduct(
        barcode: widget.barcode,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        totalQuantity: int.parse(_quantityController.text),
        quantityUnit: _selectedUnit,
      );

      final success = await ProductDatabaseService.addProduct(product);

      if (success) {
        Navigator.of(context).pop(product);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textLang('Ошибка при сохранении продукта'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(textLang('Ошибка: $e'))));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(textLang('Добавить продукт')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Штрих-код: ${widget.barcode}',
                style: TextStyle(color: AppColor.greyText, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization
                    .words, // Автоматически заглавные буквы для каждого слова
                decoration: InputDecoration(
                  labelText: textLang('Название продукта'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return textLang('Введите название продукта');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization
                    .sentences, // Заглавная буква для предложений
                decoration: InputDecoration(
                  labelText: textLang('Описание (необязательно)'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: textLang('Количество'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return textLang('Введите количество');
                        }
                        if (int.tryParse(value) == null) {
                          return textLang('Введите число');
                        }
                        if (int.parse(value) <= 0) {
                          return textLang('Количество должно быть больше 0');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: textLang('Единица'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(textLang('Отмена')),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.darkBlue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(textLang('Сохранить')),
        ),
      ],
    );
  }
}
