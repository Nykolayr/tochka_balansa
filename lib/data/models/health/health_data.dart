import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum HealthMetricType {
  bloodPressure,
  weight,
  pulse,
  bloodSugar,
  temperature,
  sleep,
  steps,
  water,
  custom;

  String get title => switch (this) {
    bloodPressure => 'Давление',
    weight => 'Вес',
    pulse => 'Пульс',
    bloodSugar => 'Сахар в крови',
    temperature => 'Температура',
    sleep => 'Сон',
    steps => 'Шаги',
    water => 'Вода',
    custom => 'Своё измерение',
  };

  String get unit => switch (this) {
    bloodPressure => 'мм.рт.ст.',
    weight => 'кг',
    pulse => 'уд/мин',
    bloodSugar => 'ммоль/л',
    temperature => '°C',
    sleep => 'ч',
    steps => 'шагов',
    water => 'мл',
    custom => '',
  };

  IconData get icon => switch (this) {
    bloodPressure => Icons.favorite,
    weight => Icons.monitor_weight,
    pulse => Icons.favorite_border,
    bloodSugar => Icons.bloodtype,
    temperature => Icons.thermostat,
    sleep => Icons.bedtime,
    steps => Icons.directions_walk,
    water => Icons.water_drop,
    custom => Icons.add_chart,
  };
}

class HealthMetric extends Equatable {
  final String id;
  final HealthMetricType type;
  final String value;
  final String? secondaryValue; // Например, для давления: 120/80
  final DateTime timestamp;
  final String? note;
  final String? customName;
  final String? customUnit;

  const HealthMetric({
    required this.id,
    required this.type,
    required this.value,
    this.secondaryValue,
    required this.timestamp,
    this.note,
    this.customName,
    this.customUnit,
  });

  String get displayName =>
      type == HealthMetricType.custom ? customName ?? type.title : type.title;

  String get displayUnit =>
      type == HealthMetricType.custom ? customUnit ?? type.unit : type.unit;

  String get displayValue =>
      secondaryValue != null ? '$value/$secondaryValue' : value;

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] as String,
      type: HealthMetricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HealthMetricType.custom,
      ),
      value: json['value'] as String,
      secondaryValue: json['secondaryValue'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      customName: json['customName'] as String?,
      customUnit: json['customUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'value': value,
      'secondaryValue': secondaryValue,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'customName': customName,
      'customUnit': customUnit,
    };
  }

  HealthMetric copyWith({
    String? id,
    HealthMetricType? type,
    String? value,
    String? secondaryValue,
    DateTime? timestamp,
    String? note,
    String? customName,
    String? customUnit,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      customName: customName ?? this.customName,
      customUnit: customUnit ?? this.customUnit,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    value,
    secondaryValue,
    timestamp,
    note,
    customName,
    customUnit,
  ];
}

class HealthData extends Equatable {
  final List<HealthMetric> metrics;

  const HealthData({required this.metrics});

  factory HealthData.initial() => const HealthData(metrics: []);

  factory HealthData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> metricsJson = json['metrics'] as List<dynamic>;
    final metrics = metricsJson
        .map((e) => HealthMetric.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return HealthData(metrics: metrics);
  }

  Map<String, dynamic> toJson() {
    return {'metrics': metrics.map((e) => e.toJson()).toList()};
  }

  HealthData copyWith({List<HealthMetric>? metrics}) {
    return HealthData(metrics: metrics ?? this.metrics);
  }

  @override
  List<Object?> get props => [metrics];
}
