// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/services/drug_database_service.dart';

class AddDrugDialog extends StatefulWidget {
  final String barcode;

  const AddDrugDialog({super.key, required this.barcode});

  @override
  State<AddDrugDialog> createState() => _AddDrugDialogState();
}

class _AddDrugDialogState extends State<AddDrugDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUnit = 'таблеток';
  bool _isLoading = false;

  final List<String> _units = [
    'таблеток',
    'капсул',
    'мл',
    'грамм',
    'штук',
    'доз',
    'порций',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveDrug() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final drug = DrugDatabaseService.createDrug(
        barcode: widget.barcode,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        totalQuantity: int.parse(_quantityController.text),
        quantityUnit: _selectedUnit,
      );

      final success = await DrugDatabaseService.addDrug(drug);

      if (success) {
        Navigator.of(context).pop(drug);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textLang('Ошибка при сохранении лекарства'))),
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
      title: Text(textLang('Добавить лекарство')),
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
                decoration: InputDecoration(
                  labelText: textLang('Название лекарства'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return textLang('Введите название лекарства');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
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
          onPressed: _isLoading ? null : _saveDrug,
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
