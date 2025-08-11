import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

enum BmiCategory {
  severeUnderweight,
  underweight,
  normal,
  overweight,
  obeseClass1,
  obeseClass2,
  obeseClass3;

  /// Получить категорию ИМТ по значению
  static BmiCategory fromValue(double bmi) {
    if (bmi < 16) {
      return BmiCategory.severeUnderweight;
    } else if (bmi < 18.5) {
      return BmiCategory.underweight;
    } else if (bmi < 25) {
      return BmiCategory.normal;
    } else if (bmi < 30) {
      return BmiCategory.overweight;
    } else if (bmi < 35) {
      return BmiCategory.obeseClass1;
    } else if (bmi < 40) {
      return BmiCategory.obeseClass2;
    } else {
      return BmiCategory.obeseClass3;
    }
  }

  /// Название категории
  String get title => switch (this) {
    severeUnderweight => textLang('Выраженный дефицит массы'),
    underweight => textLang('Недостаточная масса'),
    normal => textLang('Нормальная масса'),
    overweight => textLang('Избыточная масса'),
    obeseClass1 => textLang('Ожирение I степени'),
    obeseClass2 => textLang('Ожирение II степени'),
    obeseClass3 => textLang('Ожирение III степени'),
  };

  /// Цвет для отображения категории
  Color get color => switch (this) {
    severeUnderweight => Colors.blue[800]!,
    underweight => Colors.blue,
    normal => Colors.green,
    overweight => Colors.orange,
    obeseClass1 => Colors.orange[700]!,
    obeseClass2 => Colors.red[400]!,
    obeseClass3 => Colors.red[900]!,
  };

  /// Минимальное значение ИМТ для данной категории
  double get minValue => switch (this) {
    severeUnderweight => 0,
    underweight => 16,
    normal => 18.5,
    overweight => 25,
    obeseClass1 => 30,
    obeseClass2 => 35,
    obeseClass3 => 40,
  };

  /// Максимальное значение ИМТ для данной категории
  double get maxValue => switch (this) {
    severeUnderweight => 16,
    underweight => 18.5,
    normal => 25,
    overweight => 30,
    obeseClass1 => 35,
    obeseClass2 => 40,
    obeseClass3 => double.infinity,
  };

  /// Рекомендации по категории ИМТ
  String get recommendation => switch (this) {
    severeUnderweight => textLang(
      'Увеличьте калорийность рациона, добавьте белковую пищу и здоровые жиры. Рекомендуется консультация с врачом для исключения заболеваний',
    ),
    underweight => textLang(
      'Добавьте в рацион больше калорийной и питательной пищи, увеличьте частоту приемов пищи и включите силовые тренировки',
    ),
    normal => textLang(
      'Поддерживайте сбалансированное питание и регулярную физическую активность. Ваш вес находится в оптимальном диапазоне',
    ),
    overweight => textLang(
      'Создайте небольшой дефицит калорий, увеличьте потребление белка и клетчатки, добавьте кардио и силовые тренировки',
    ),
    obeseClass1 => textLang(
      'Создайте дефицит калорий через здоровое питание и регулярные физические упражнения',
    ),
    obeseClass2 => textLang(
      'Сократите потребление простых углеводов, увеличьте физическую активность и контролируйте размер порций. Рекомендуется консультация врача',
    ),
    obeseClass3 => textLang(
      'Следуйте принципам здорового питания и постепенно увеличивайте физическую активность. Необходима консультация врача для составления безопасного плана снижения веса',
    ),
  };

  /// Коэффициент ширины для блока ИМТ (в процентах от ширины SVG)
  double get widthCoefficient => switch (this) {
    severeUnderweight => 0.5, // 50% от ширины SVG
    underweight => 0.55,      // 55% от ширины SVG
    normal => 0.6,            // 60% от ширины SVG
    overweight => 0.65,       // 65% от ширины SVG
    obeseClass1 => 0.7,       // 70% от ширины SVG
    obeseClass2 => 0.75,      // 75% от ширины SVG
    obeseClass3 => 0.8,       // 80% от ширины SVG
  };
}
