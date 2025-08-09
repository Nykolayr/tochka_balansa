import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

enum BloodPressureCategory {
  optimal,
  normal,
  highNormal,
  hypertension1,
  hypertension2,
  hypertension3,
  isolatedSystolic;

  String get title {
    switch (this) {
      case BloodPressureCategory.optimal:
        return 'Оптимальное';
      case BloodPressureCategory.normal:
        return 'Нормальное';
      case BloodPressureCategory.highNormal:
        return 'Высокое нормальное';
      case BloodPressureCategory.hypertension1:
        return 'Гипертония 1 степени';
      case BloodPressureCategory.hypertension2:
        return 'Гипертония 2 степени';
      case BloodPressureCategory.hypertension3:
        return 'Гипертония 3 степени';
      case BloodPressureCategory.isolatedSystolic:
        return 'Изолированная систолическая гипертония';
    }
  }

  Color get color {
    switch (this) {
      case BloodPressureCategory.optimal:
        return AppColor.green;
      case BloodPressureCategory.normal:
        return AppColor.green;
      case BloodPressureCategory.highNormal:
        return Colors.orange;
      case BloodPressureCategory.hypertension1:
        return Colors.orange;
      case BloodPressureCategory.hypertension2:
        return Colors.red;
      case BloodPressureCategory.hypertension3:
        return Colors.red;
      case BloodPressureCategory.isolatedSystolic:
        return Colors.orange;
    }
  }

  String get recommendation {
    switch (this) {
      case BloodPressureCategory.optimal:
        return 'Отличные показатели! Продолжайте вести здоровый образ жизни.';
      case BloodPressureCategory.normal:
        return 'Нормальные показатели. Поддерживайте активность и правильное питание.';
      case BloodPressureCategory.highNormal:
        return 'Показатели повышены. Рекомендуется снизить потребление соли, больше двигаться.';
      case BloodPressureCategory.hypertension1:
        return 'Легкая гипертония. Обратитесь к врачу для консультации и корректировки образа жизни.';
      case BloodPressureCategory.hypertension2:
        return 'Умеренная гипертония. Обязательно обратитесь к врачу для назначения лечения.';
      case BloodPressureCategory.hypertension3:
        return 'Тяжелая гипертония. Срочно обратитесь к врачу! Требуется медикаментозное лечение.';
      case BloodPressureCategory.isolatedSystolic:
        return 'Изолированная систолическая гипертония. Консультация кардиолога обязательна.';
    }
  }

  static BloodPressureCategory getCategory(int systolic, int diastolic) {
    // Классификация по стандартам ESC/ESH
    if (systolic < 120 && diastolic < 80) {
      return BloodPressureCategory.optimal;
    } else if (systolic < 130 && diastolic < 85) {
      return BloodPressureCategory.normal;
    } else if (systolic < 140 && diastolic < 90) {
      return BloodPressureCategory.highNormal;
    } else if (systolic >= 180 || diastolic >= 110) {
      return BloodPressureCategory.hypertension3;
    } else if (systolic >= 160 || diastolic >= 100) {
      return BloodPressureCategory.hypertension2;
    } else if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.hypertension1;
    } else if (systolic >= 140 && diastolic < 90) {
      return BloodPressureCategory.isolatedSystolic;
    }

    return BloodPressureCategory.normal;
  }
}

enum PulseCategory {
  bradycardia,
  normal,
  tachycardia;

  String get title {
    switch (this) {
      case PulseCategory.bradycardia:
        return 'Брадикардия';
      case PulseCategory.normal:
        return 'Нормальный';
      case PulseCategory.tachycardia:
        return 'Тахикардия';
    }
  }

  Color get color {
    switch (this) {
      case PulseCategory.bradycardia:
        return Colors.orange;
      case PulseCategory.normal:
        return AppColor.green;
      case PulseCategory.tachycardia:
        return Colors.orange;
    }
  }

  String get recommendation {
    switch (this) {
      case PulseCategory.bradycardia:
        return 'Замедленный пульс. Обратитесь к врачу если есть симптомы слабости или головокружения.';
      case PulseCategory.normal:
        return 'Пульс в норме. Продолжайте поддерживать физическую активность.';
      case PulseCategory.tachycardia:
        return 'Учащенный пульс. Избегайте стресса, кофеина. При регулярном учащении - к врачу.';
    }
  }

  static PulseCategory getCategory(int pulse) {
    if (pulse < 60) {
      return PulseCategory.bradycardia;
    } else if (pulse > 100) {
      return PulseCategory.tachycardia;
    }
    return PulseCategory.normal;
  }
}
