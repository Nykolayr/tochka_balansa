import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/bmi_category.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

class WeightBlockWidget extends StatelessWidget {
  final HealthMetric? latestWeight;
  final Function() onAddWeightPressed;
  final Function() onViewWeightPressed;

  const WeightBlockWidget({
    super.key,
    required this.latestWeight,
    required this.onAddWeightPressed,
    required this.onViewWeightPressed,
  });

  @override
  Widget build(BuildContext context) {
    final userRepository = Get.find<UserRepository>();
    final user = userRepository.user;
    final height = user.height;
    final initialWeight = user.initialWeight;
    final currentWeight = latestWeight != null
        ? double.tryParse(latestWeight!.value) ?? initialWeight
        : initialWeight;

    // Расчет ИМТ (Индекс массы тела)
    double bmi = 0;
    BmiCategory? bmiCategory;

    if (height > 0 && currentWeight > 0) {
      bmi = currentWeight / ((height / 100) * (height / 100));
      bmiCategory = BmiCategory.fromValue(bmi);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя часть с весом
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок "Текущий вес"
                    Text(
                      textLang('Текущий вес'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.greyText.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Значение веса
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currentWeight.toStringAsFixed(
                            1,
                          ), // Форматируем до одного знака
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'кг',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.greyText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (latestWeight != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(latestWeight!.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // ИМТ в одну строку с блоком
            Row(
              children: [
                // Заголовок ИМТ
                Text(
                  textLang('ИМТ:'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColor.greyText.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 12),

                if (bmiCategory != null) ...[
                  // Блок с ИМТ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: bmiCategory.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bmiCategory.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 1,
                          height: 16,
                          color: bmiCategory.color.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bmiCategory.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: bmiCategory.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Если ИМТ не удалось рассчитать
                  Text(
                    '—',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Кнопки добавления и просмотра
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAddWeightPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(textLang('Добавить вес')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewWeightPressed,
                    icon: const Icon(Icons.bar_chart, size: 18),
                    label: Text(textLang('Просмотр')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.greyText.withValues(alpha: 0.2),
                      foregroundColor: AppColor.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Изменение веса (если есть)
            if (initialWeight > 0 && initialWeight != currentWeight)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      (currentWeight > initialWeight
                              ? Colors.red
                              : Colors.green)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        (currentWeight > initialWeight
                                ? Colors.red
                                : Colors.green)
                            .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentWeight > initialWeight
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: currentWeight > initialWeight
                          ? Colors.red
                          : Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(currentWeight - initialWeight).abs().toStringAsFixed(1)} кг',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: currentWeight > initialWeight
                            ? Colors.red
                            : Colors.green,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
