import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/theme.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/health/bmi_category.dart';
import 'package:tochka_balansa/data/models/health/health_data.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyOutlineWidget extends StatelessWidget {
  const BodyOutlineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthBloc, HealthState>(
      bloc: Get.find<HealthBloc>(),
      builder: (context, state) {
        final userRepository = Get.find<UserRepository>();
        final user = userRepository.user;

        final latestWeight = _getLatestWeight(state);
        final currentWeight = latestWeight != null
            ? double.tryParse(latestWeight.value) ?? user.initialWeight
            : user.initialWeight;

        double bmi = 0;
        BmiCategory? bmiCategory;

        if (user.height > 0 && currentWeight > 0) {
          bmi = currentWeight / ((user.height / 100) * (user.height / 100));
          bmiCategory = BmiCategory.fromValue(bmi);
        }

        final bodyOutlineAsset = _getBodyOutlineAsset(user.gender, bmiCategory);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end, // Выравнивание по низу
            children: [
              // Виджет 1: Сосуд "Съедено"
              Expanded(child: _buildConsumedVessel()),

              const SizedBox(width: 10),

              // Виджет 2: Центральный с человеком и ИМТ (ширина на основе коэффициента ИМТ)
              SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.6 *
                    (bmiCategory?.widthCoefficient ??
                        0.6), // Ширина на основе коэффициента
                child: _buildCenterWidget(
                  bodyOutlineAsset: bodyOutlineAsset,
                  currentWeight: currentWeight,
                  bmi: bmi,
                  bmiCategory: bmiCategory,
                ),
              ),

              const SizedBox(width: 10),

              // Виджет 3: Сосуд "Сожжено"
              Expanded(child: _buildBurnedVessel()),
            ],
          ),
        );
      },
    );
  }

  // Виджет 1: Сосуд "Съедено"
  Widget _buildConsumedVessel() {
    return Column(
      children: [
        Text(
          textLang('съедено'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.vesselBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '3004',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.vesselBlue,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 270,
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.vesselBlue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 250 * 0.6,
                  decoration: BoxDecoration(
                    color: AppColor.vesselFillBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.vesselBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Виджет 2: Центральный с человеком и ИМТ
  Widget _buildCenterWidget({
    required String bodyOutlineAsset,
    required double currentWeight,
    required double bmi,
    required BmiCategory? bmiCategory,
  }) {
    return Column(
      children: [
        Text(
          '${textLang('баланс')}: -1004',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              bodyOutlineAsset,
              height: 250,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (bmiCategory != null)
          Container(
            width: 200 * (bmiCategory.widthCoefficient),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: bmiCategory.color,
                  ),
                ),
                const SizedBox(height: 4),
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

  // Виджет 3: Сосуд "Сожжено"
  Widget _buildBurnedVessel() {
    return Column(
      children: [
        Text(
          textLang('сожжено'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '2000',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 270,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 250 * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
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

  String _getBodyOutlineAsset(Gender gender, BmiCategory? bmiCategory) {
    if (bmiCategory == null) {
      return gender == Gender.male
          ? 'assets/svg/body_outline_male_normal.svg'
          : 'assets/svg/body_outline_female_normal.svg';
    }
    final genderSuffix = gender == Gender.male ? 'male' : 'female';
    switch (bmiCategory) {
      case BmiCategory.severeUnderweight:
      case BmiCategory.underweight:
        return 'assets/svg/body_outline_${genderSuffix}_underweight.svg';
      case BmiCategory.normal:
        return 'assets/svg/body_outline_${genderSuffix}_normal.svg';
      case BmiCategory.overweight:
        return 'assets/svg/body_outline_${genderSuffix}_overweight.svg';
      case BmiCategory.obeseClass1:
        return 'assets/svg/body_outline_${genderSuffix}_obese.svg';
      case BmiCategory.obeseClass2:
      case BmiCategory.obeseClass3:
        return 'assets/svg/body_outline_${genderSuffix}_extremely_obese.svg';
    }
  }
}
