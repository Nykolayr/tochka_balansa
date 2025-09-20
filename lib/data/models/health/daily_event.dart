import 'package:equatable/equatable.dart';

/// Тип события
enum EventType {
  // Съедено
  breakfast,
  lunch,
  dinner,
  snacks,

  // Сожжено
  steps,
  exercise,
  bmr, // Расходы организма
}

/// Базовый класс для событий дня
abstract class DailyEvent extends Equatable {
  final String id;
  final EventType type;
  final DateTime timestamp;
  final int calories;
  final String? note;

  const DailyEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.calories,
    this.note,
  });

  @override
  List<Object?> get props => [id, type, timestamp, calories, note];
}

/// Событие съедено (прием пищи)
class ConsumedEvent extends DailyEvent {
  final List<String> products; // Названия продуктов
  final int totalWeight; // Общий вес в граммах

  const ConsumedEvent({
    required super.id,
    required super.type,
    required super.timestamp,
    required super.calories,
    required this.products,
    required this.totalWeight,
    super.note,
  });

  factory ConsumedEvent.create({
    required EventType type,
    required List<String> products,
    required int totalWeight,
    required int calories,
    String? note,
  }) {
    return ConsumedEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      timestamp: DateTime.now(),
      calories: calories,
      products: products,
      totalWeight: totalWeight,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'calories': calories,
      'products': products,
      'totalWeight': totalWeight,
      'note': note,
    };
  }

  factory ConsumedEvent.fromJson(Map<String, dynamic> json) {
    return ConsumedEvent(
      id: json['id'] as String,
      type: EventType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      calories: json['calories'] as int,
      products: List<String>.from(json['products'] as List),
      totalWeight: json['totalWeight'] as int,
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [...super.props, products, totalWeight];
}

/// Событие сожжено (активность)
class BurnedEvent extends DailyEvent {
  final int? quantity; // Количество (шаги, минуты упражнений)
  final String? unit; // Единица измерения

  const BurnedEvent({
    required super.id,
    required super.type,
    required super.timestamp,
    required super.calories,
    this.quantity,
    this.unit,
    super.note,
  });

  factory BurnedEvent.create({
    required EventType type,
    required int calories,
    int? quantity,
    String? unit,
    String? note,
  }) {
    return BurnedEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      timestamp: DateTime.now(),
      calories: calories,
      quantity: quantity,
      unit: unit,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'calories': calories,
      'quantity': quantity,
      'unit': unit,
      'note': note,
    };
  }

  factory BurnedEvent.fromJson(Map<String, dynamic> json) {
    return BurnedEvent(
      id: json['id'] as String,
      type: EventType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      calories: json['calories'] as int,
      quantity: json['quantity'] as int?,
      unit: json['unit'] as String?,
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [...super.props, quantity, unit];
}

/// Расширение для EventType
extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.breakfast:
        return 'Завтрак';
      case EventType.lunch:
        return 'Обед';
      case EventType.dinner:
        return 'Ужин';
      case EventType.snacks:
        return 'Перекус';
      case EventType.steps:
        return 'Шаги';
      case EventType.exercise:
        return 'Упражнения';
      case EventType.bmr:
        return 'Расходы организма';
    }
  }

  bool get isConsumed {
    return this == EventType.breakfast ||
        this == EventType.lunch ||
        this == EventType.dinner ||
        this == EventType.snacks;
  }

  bool get isBurned {
    return this == EventType.steps ||
        this == EventType.exercise ||
        this == EventType.bmr;
  }
}
