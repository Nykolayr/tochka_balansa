import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';

enum BloodSugarCategory {
  hypoglycemia, // Гипогликемия
  normal, // Норма
  prediabetes, // Предиабет
  diabetesType1, // Диабет 1 типа
  diabetesType2, // Диабет 2 типа
  gestationalDiabetes, // Гестационный диабет
  critical; // Критический уровень

  /// Получить категорию сахара в крови по значению
  static BloodSugarCategory fromValue(double sugar, {bool isFasting = true}) {
    if (isFasting) {
      // Натощак (8-12 часов без еды)
      if (sugar < 3.3) {
        return BloodSugarCategory.hypoglycemia;
      } else if (sugar < 5.6) {
        return BloodSugarCategory.normal;
      } else if (sugar < 6.1) {
        return BloodSugarCategory.prediabetes;
      } else if (sugar < 7.0) {
        return BloodSugarCategory.diabetesType2;
      } else {
        return BloodSugarCategory.critical;
      }
    } else {
      // После еды (2 часа)
      if (sugar < 3.3) {
        return BloodSugarCategory.hypoglycemia;
      } else if (sugar < 7.8) {
        return BloodSugarCategory.normal;
      } else if (sugar < 11.1) {
        return BloodSugarCategory.prediabetes;
      } else {
        return BloodSugarCategory.critical;
      }
    }
  }

  /// Название категории
  String get title => switch (this) {
    hypoglycemia => textLang('Гипогликемия'),
    normal => textLang('Норма'),
    prediabetes => textLang('Предиабет'),
    diabetesType1 => textLang('Диабет 1 типа'),
    diabetesType2 => textLang('Диабет 2 типа'),
    gestationalDiabetes => textLang('Гестационный диабет'),
    critical => textLang('Критический уровень'),
  };

  /// Цвет для отображения категории
  Color get color => switch (this) {
    hypoglycemia => Colors.red[700]!, // ИЗМЕНЕНО: красный для гипогликемии
    normal => Colors.green,
    prediabetes => Colors.orange,
    diabetesType1 => Colors.red[400]!,
    diabetesType2 => Colors.red[600]!,
    gestationalDiabetes => Colors.purple,
    critical => Colors.red[900]!,
  };

  /// Рекомендации по категории сахара в крови
  String get recommendation => switch (this) {
    hypoglycemia => textLang(
      'Немедленно съешьте что-то сладкое (сахар, мед, сок). Контролируйте уровень сахара и обратитесь к врачу для выяснения причин',
    ),
    normal => textLang(
      'Поддерживайте здоровый образ жизни: сбалансированное питание, регулярная физическая активность и контроль веса',
    ),
    prediabetes => textLang(
      'Снизьте потребление простых углеводов, увеличьте физическую активность, контролируйте вес. Рекомендуется консультация врача',
    ),
    diabetesType1 => textLang(
      'Необходим регулярный контроль сахара, инсулинотерапия, диета и физическая активность. Обязательно наблюдайтесь у эндокринолога',
    ),
    diabetesType2 => textLang(
      'Соблюдайте диету, контролируйте вес, регулярно занимайтесь спортом. При необходимости принимайте назначенные врачом препараты',
    ),
    gestationalDiabetes => textLang(
      'Соблюдайте специальную диету для беременных, контролируйте сахар, регулярно посещайте врача. Обычно проходит после родов',
    ),
    critical => textLang(
      'Немедленно обратитесь к врачу! Возможно, требуется экстренная медицинская помощь и коррекция лечения',
    ),
  };
}
