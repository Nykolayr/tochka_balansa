import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/health/bmi_category.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tochka_balansa/presentation/pages/home/widgets/add_food_dialog.dart';
import 'package:tochka_balansa/presentation/pages/home/widgets/consumed_vessel_widget.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';

class BodyOutlineWidget extends StatelessWidget {
  const BodyOutlineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      bloc: Get.find<MainBloc>(),
      builder: (context, mainState) {
        return BlocBuilder<HealthBloc, HealthState>(
          bloc: Get.find<HealthBloc>(),
          builder: (context, healthState) {
            final userRepository = Get.find<UserRepository>();
            final user = userRepository.user;

            final latestWeight = _getLatestWeight(healthState);
            final currentWeight = latestWeight != null
                ? double.tryParse(latestWeight.value) ?? user.initialWeight
                : user.initialWeight;

            double bmi = 0;
            BmiCategory? bmiCategory;

            if (user.height > 0 && currentWeight > 0) {
              bmi = currentWeight / ((user.height / 100) * (user.height / 100));
              bmiCategory = BmiCategory.fromValue(bmi);
            }

            final bodyOutlineAsset =
                bmiCategory?.getBodyOutlineAsset(user.gender) ??
                'assets/svg/body_outline_${user.gender == Gender.male ? 'male' : 'female'}_normal.svg';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Виджет 1: Сосуд "Съедено"
                      Expanded(
                        child: ConsumedVesselWidget(
                          isVessel: true,
                          value: mainState.consumedCalories,
                          maxValue: mainState.maxCalories,
                          onTap: (value) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const AddFoodDialog(),
                            );
                          },
                        ),
                      ),
                      // Виджет 2: Центральный с человеком и ИМТ
                      SizedBox(
                        height: 370,
                        width:
                            MediaQuery.of(context).size.width *
                            0.6 *
                            (bmiCategory?.widthCoefficient ?? 0.6),
                        child: _buildCenterWidget(
                          context: context,
                          mainState: mainState,
                          healthState: healthState,
                          bodyOutlineAsset: bodyOutlineAsset,
                          currentWeight: currentWeight,
                          bmi: bmi,
                          bmiCategory: bmiCategory,
                          balance:
                              mainState.consumedCalories -
                              mainState
                                  .burnedCalories, // НОВОЕ: баланс из MainBloc
                        ),
                      ),
                      // Виджет 3: Сосуд "Сожжено"
                      Expanded(
                        child: ConsumedVesselWidget(
                          isVessel: false,
                          value: mainState.burnedCalories,
                          maxValue: mainState.maxCalories,
                          onTap: (value) {
                            // НОВОЕ: показываем диалог добавления сожженных калорий
                            // TODO: создать AddBurnedCaloriesDialog
                            Logger.i('Добавить сожженные калории: $value');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Обновляю _buildCenterWidget, чтобы он правильно показывал баланс
  Widget _buildCenterWidget({
    required BuildContext context,
    required MainState mainState,
    required HealthState healthState,
    required String bodyOutlineAsset,
    required double currentWeight,
    required double bmi,
    required BmiCategory? bmiCategory,
    required int balance, // баланс калорий
  }) {
    // Правильная логика: если сожгли больше чем съели = хорошо (зеленый, +)
    final isPositive =
        balance <=
        0; // balance <= 0 означает сожгли больше или равно съеденному

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${textLang('баланс')}: ${isPositive ? '+' : ''}${balance.abs()}', // Показываем + если хорошо, - если плохо
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isPositive
                ? Colors.green
                : Colors.red, // Зеленый если хорошо, красный если плохо
          ),
        ),
        const Gap(16),
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              bodyOutlineAsset,
              height: 270,
              colorFilter: ColorFilter.mode(
                bmiCategory?.color ?? AppColor.greyText,
                BlendMode.srcIn,
              ),
            ),
            Positioned(
              top: 100,
              child: Text(
                '${currentWeight.toStringAsFixed(1)} кг',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const Gap(6),
        if (bmiCategory != null)
          Container(
            padding: const EdgeInsets.all(5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'ИМТ: ${bmi.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: bmiCategory.color,
                  ),
                ),
                const Gap(3),
                Text(
                  bmiCategory.title,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  HealthMetric? _getLatestWeight(HealthState state) {
    if (state.healthData.metrics.isEmpty) return null;
    final weightMetrics = state.healthData.metrics
        .where((m) => m.type == HealthMetricType.weight)
        .toList();
    if (weightMetrics.isEmpty) return null;
    weightMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return weightMetrics.first;
  }
}
