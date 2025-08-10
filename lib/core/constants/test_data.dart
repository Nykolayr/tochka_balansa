class TestData {
  static const List<Map<String, dynamic>> weightData = [
    // Убираем тестовые данные, используем реальные
    {'daysOffset': 60, 'weight': 75.0}, // 60 дней назад
    {'daysOffset': 58, 'weight': 75.1},
    {'daysOffset': 56, 'weight': 75.2},
    {'daysOffset': 54, 'weight': 75.3},
    {'daysOffset': 52, 'weight': 75.4},
    {'daysOffset': 50, 'weight': 75.5},
    {'daysOffset': 48, 'weight': 75.6},
    {'daysOffset': 46, 'weight': 75.7},
    {'daysOffset': 44, 'weight': 75.8},
    {'daysOffset': 42, 'weight': 75.9},
    {'daysOffset': 40, 'weight': 76.0},
    {'daysOffset': 38, 'weight': 76.1},
    {'daysOffset': 36, 'weight': 76.2},
    {'daysOffset': 34, 'weight': 76.3},
    {'daysOffset': 32, 'weight': 76.4},
    {'daysOffset': 30, 'weight': 76.5},
    {'daysOffset': 28, 'weight': 76.6},
    {'daysOffset': 26, 'weight': 76.7},
    {'daysOffset': 24, 'weight': 76.8},
    {'daysOffset': 22, 'weight': 76.9},
    {'daysOffset': 20, 'weight': 77.0},
    {'daysOffset': 18, 'weight': 77.1},
    {'daysOffset': 16, 'weight': 77.2},
    {'daysOffset': 14, 'weight': 77.3},
    {'daysOffset': 12, 'weight': 77.4},
    {'daysOffset': 10, 'weight': 77.5},
    {'daysOffset': 9, 'weight': 77.6},
    {'daysOffset': 8, 'weight': 77.7},
    {'daysOffset': 7, 'weight': 77.8},
    {'daysOffset': 6, 'weight': 77.9},
    {'daysOffset': 5, 'weight': 78.0},
    {'daysOffset': 4, 'weight': 78.1},
    {'daysOffset': 3, 'weight': 78.2},
    {'daysOffset': 2, 'weight': 78.3},
    {'daysOffset': 1, 'weight': 78.4},
    {'daysOffset': 0, 'weight': 78.5}, // Сегодня
    // ДОБАВЛЯЕМ НОВЫЕ ЗНАЧЕНИЯ ДЛЯ 6 МЕСЯЦЕВ
    {'daysOffset': 90, 'weight': 74.5}, // 3 месяца назад
    {'daysOffset': 120, 'weight': 74.0}, // 4 месяца назад
    {'daysOffset': 150, 'weight': 73.5}, // 5 месяцев назад
    {'daysOffset': 180, 'weight': 73.0}, // 6 месяцев назад
  ];

  static const List<Map<String, dynamic>> bloodPressureData = [
    {
      'daysOffset': 60,
      'systolic': 140,
      'diastolic': 90,
      'pulse': 80,
    }, // 60 дней назад
    {'daysOffset': 58, 'systolic': 139, 'diastolic': 89, 'pulse': 79},
    {'daysOffset': 56, 'systolic': 138, 'diastolic': 88, 'pulse': 78},
    {'daysOffset': 54, 'systolic': 137, 'diastolic': 87, 'pulse': 77},
    {'daysOffset': 52, 'systolic': 136, 'diastolic': 86, 'pulse': 76},
    {'daysOffset': 50, 'systolic': 135, 'diastolic': 85, 'pulse': 75},
    {'daysOffset': 48, 'systolic': 134, 'diastolic': 84, 'pulse': 74},
    {'daysOffset': 46, 'systolic': 133, 'diastolic': 83, 'pulse': 73},
    {'daysOffset': 44, 'systolic': 132, 'diastolic': 82, 'pulse': 72},
    {'daysOffset': 42, 'systolic': 131, 'diastolic': 81, 'pulse': 71},
    {'daysOffset': 40, 'systolic': 130, 'diastolic': 80, 'pulse': 70},
    {'daysOffset': 38, 'systolic': 129, 'diastolic': 79, 'pulse': 69},
    {'daysOffset': 36, 'systolic': 128, 'diastolic': 78, 'pulse': 68},
    {'daysOffset': 34, 'systolic': 127, 'diastolic': 77, 'pulse': 67},
    {'daysOffset': 32, 'systolic': 126, 'diastolic': 76, 'pulse': 66},
    {'daysOffset': 30, 'systolic': 125, 'diastolic': 75, 'pulse': 65},
    {'daysOffset': 28, 'systolic': 124, 'diastolic': 74, 'pulse': 64},
    {'daysOffset': 26, 'systolic': 123, 'diastolic': 73, 'pulse': 63},
    {'daysOffset': 24, 'systolic': 122, 'diastolic': 72, 'pulse': 62},
    {'daysOffset': 22, 'systolic': 121, 'diastolic': 71, 'pulse': 61},
    {'daysOffset': 20, 'systolic': 120, 'diastolic': 70, 'pulse': 60},
    {'daysOffset': 18, 'systolic': 119, 'diastolic': 69, 'pulse': 59},
    {'daysOffset': 16, 'systolic': 118, 'diastolic': 68, 'pulse': 58},
    {'daysOffset': 14, 'systolic': 117, 'diastolic': 67, 'pulse': 57},
    {'daysOffset': 12, 'systolic': 116, 'diastolic': 66, 'pulse': 56},
    {'daysOffset': 10, 'systolic': 115, 'diastolic': 65, 'pulse': 55},
    {'daysOffset': 9, 'systolic': 114, 'diastolic': 64, 'pulse': 54},
    {'daysOffset': 8, 'systolic': 113, 'diastolic': 63, 'pulse': 53},
    {'daysOffset': 7, 'systolic': 112, 'diastolic': 62, 'pulse': 52},
    {'daysOffset': 6, 'systolic': 111, 'diastolic': 61, 'pulse': 51},
    {'daysOffset': 5, 'systolic': 110, 'diastolic': 60, 'pulse': 50},
    {'daysOffset': 4, 'systolic': 109, 'diastolic': 59, 'pulse': 49},
    {'daysOffset': 3, 'systolic': 108, 'diastolic': 58, 'pulse': 48},
    {'daysOffset': 2, 'systolic': 107, 'diastolic': 57, 'pulse': 47},
    {'daysOffset': 1, 'systolic': 106, 'diastolic': 56, 'pulse': 46},
    {'daysOffset': 0, 'systolic': 105, 'diastolic': 55, 'pulse': 45}, // Сегодня
    // ДОБАВЛЯЕМ ДЛЯ 6 МЕСЯЦЕВ
    {
      'daysOffset': 90,
      'systolic': 145,
      'diastolic': 95,
      'pulse': 85,
    }, // 3 месяца назад
    {
      'daysOffset': 120,
      'systolic': 150,
      'diastolic': 100,
      'pulse': 90,
    }, // 4 месяца назад
    {
      'daysOffset': 150,
      'systolic': 155,
      'diastolic': 105,
      'pulse': 95,
    }, // 5 месяцев назад
    {
      'daysOffset': 180,
      'systolic': 160,
      'diastolic': 110,
      'pulse': 100,
    }, // 6 месяцев назад
  ];
}
