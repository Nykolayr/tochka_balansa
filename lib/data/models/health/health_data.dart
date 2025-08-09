import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum HealthMetricType {
  weight,
  bloodPressureAndPulse, // давление+пульс объединены
  bloodSugar, // сахар в крови
  steps, // шаги
  custom; // свой показатель

  String get title {
    switch (this) {
      case HealthMetricType.weight:
        return 'Вес';
      case HealthMetricType.bloodPressureAndPulse:
        return 'Давление и пульс';
      case HealthMetricType.bloodSugar:
        return 'Сахар в крови';
      case HealthMetricType.steps:
        return 'Шаги';
      case HealthMetricType.custom:
        return 'Другое';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthMetricType.weight:
        return Icons.monitor_weight;
      case HealthMetricType.bloodPressureAndPulse:
        return Icons.favorite;
      case HealthMetricType.bloodSugar:
        return Icons.bloodtype;
      case HealthMetricType.steps:
        return Icons.directions_walk;
      case HealthMetricType.custom:
        return Icons.add_circle_outline;
    }
  }

  String get unit {
    switch (this) {
      case HealthMetricType.weight:
        return 'кг';
      case HealthMetricType.bloodPressureAndPulse:
        return 'мм рт.ст. / уд/мин';
      case HealthMetricType.bloodSugar:
        return 'ммоль/л';
      case HealthMetricType.steps:
        return 'шагов';
      case HealthMetricType.custom:
        return '';
    }
  }
}

class HealthMetric extends Equatable {
  final String id;
  final HealthMetricType type;
  final String value;
  final DateTime timestamp;
  final String? note;

  const HealthMetric({
    required this.id,
    required this.type,
    required this.value,
    required this.timestamp,
    this.note,
  });

  // Геттер displayName для совместимости
  String get displayName => type.title;

  // Геттер displayValue для отображения значения
  String get displayValue {
    if (type == HealthMetricType.custom && value.contains(':')) {
      // Для кастомных показателей возвращаем только значение после двоеточия
      return value.split(':').last.trim();
    }
    return value;
  }

  // Геттер displayUnit для отображения единиц измерения
  String get displayUnit {
    if (type == HealthMetricType.custom && value.contains(':')) {
      // Для кастомных показателей единица измерения может быть не нужна
      return '';
    }
    return type.unit;
  }

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] as String,
      type: HealthMetricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HealthMetricType.weight,
      ),
      value: json['value'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  HealthMetric copyWith({
    String? id,
    HealthMetricType? type,
    String? value,
    DateTime? timestamp,
    String? note,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, type, value, timestamp, note];
}

class HealthData extends Equatable {
  final List<HealthMetric> metrics;

  const HealthData({this.metrics = const []});

  factory HealthData.initial() => const HealthData(metrics: []);

  factory HealthData.fromJson(Map<String, dynamic> json) {
    final metricsList = json['metrics'] as List<dynamic>? ?? [];
    return HealthData(
      metrics: metricsList
          .map(
            (metric) => HealthMetric.fromJson(metric as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'metrics': metrics.map((metric) => metric.toJson()).toList()};
  }

  HealthData copyWith({List<HealthMetric>? metrics}) {
    return HealthData(metrics: metrics ?? this.metrics);
  }

  @override
  List<Object?> get props => [metrics];
}
