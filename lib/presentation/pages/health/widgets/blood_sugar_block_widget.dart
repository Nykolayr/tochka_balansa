import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/models/health/blood_sugar_category.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/widgets/add_blood_sugar_dialog.dart';
import 'package:go_router/go_router.dart';

class BloodSugarBlockWidget extends StatelessWidget {
  const BloodSugarBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      bloc: Get.find<HealthBloc>(),
      builder: (context, state) {
        final sugarMetrics = state.healthData.metrics
            .where((m) => m.type == HealthMetricType.bloodSugar)
            .toList();

        if (sugarMetrics.isEmpty) {
          return const SizedBox.shrink();
        }

        sugarMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        final lastMeasurement = sugarMetrics.first.value;
        final currentSugar = double.tryParse(lastMeasurement) ?? 0.0;

        // Получаем предыдущее измерение для сравнения
        double? previousSugar;
        if (sugarMetrics.length > 1) {
          previousSugar = double.tryParse(sugarMetrics[1].value);
        }

        // Определяем категорию сахара в крови
        final sugarCategory = BloodSugarCategory.fromValue(currentSugar);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок по центру
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textLang('Мониторинг сахара в крови'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ROW с двумя COLUMN'ами и виджетом
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Первый COLUMN: "Сахар в крови" + значение
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textLang('Сахар в крови'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.greyText.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              currentSugar.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'ммоль/л',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.greyText.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Второй COLUMN: стрелка + значение изменения
                    if (previousSugar != null &&
                        currentSugar != previousSugar) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(
                            height: 16,
                          ), // выравнивание с первым column
                          Icon(
                            currentSugar > previousSugar
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: currentSugar > previousSugar
                                ? Colors.red
                                : Colors.green,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (currentSugar - previousSugar)
                                .abs()
                                .toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: currentSugar > previousSugar
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                    ],

                    // Виджет состояния (растягивается по оставшейся ширине)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: sugarCategory.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          sugarCategory.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: sugarCategory.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Рекомендация
                Text(
                  sugarCategory.recommendation,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.greyText.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 16),

                // Кнопки добавления и просмотра
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => AddBloodSugarDialog.show(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(textLang('Добавить')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Используем go_router вместо Navigator
                          context.push('/main/health/blood-sugar');
                        },
                        icon: const Icon(Icons.bar_chart, size: 18),
                        label: Text(textLang('Просмотр')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.greyText.withValues(
                            alpha: 0.2,
                          ),
                          foregroundColor: AppColor.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
