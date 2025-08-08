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
      'Необходима консультация врача для набора веса',
    ),
    underweight => textLang('Рекомендуется увеличить калорийность питания'),
    normal => textLang('Поддерживайте текущий образ жизни'),
    overweight => textLang('Рекомендуется умеренное снижение веса'),
    obeseClass1 => textLang('Рекомендуется снижение веса под контролем врача'),
    obeseClass2 => textLang('Необходима консультация врача для снижения веса'),
    obeseClass3 => textLang('Требуется срочная консультация врача'),
  };
}
