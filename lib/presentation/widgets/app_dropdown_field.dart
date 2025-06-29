import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemText;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemText,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(label, style: AppText.text16rb),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemText(item), style: AppText.text16rb),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
