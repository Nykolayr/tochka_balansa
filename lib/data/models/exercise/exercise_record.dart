import 'package:equatable/equatable.dart';

/// Модель записи упражнения
class ExerciseRecord extends Equatable {
  final String id;
  final String name;
  final double amount; // Количество
  final String unit; // Единица измерения (км, раз, мин и т.д.)
  final int caloriesPerUnit; // Калории на единицу измерения
  final DateTime timestamp;
  final String? note; // Заметка

  const ExerciseRecord({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.caloriesPerUnit,
    required this.timestamp,
    this.note,
  });

  factory ExerciseRecord.create({
    required String name,
    required double amount,
    required String unit,
    required int caloriesPerUnit,
    String? note,
  }) {
    return ExerciseRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
      unit: unit,
      caloriesPerUnit: caloriesPerUnit,
      timestamp: DateTime.now(),
      note: note,
    );
  }

  /// Получить общие калории упражнения
  int get totalCalories => (amount * caloriesPerUnit).round();

  /// Получить отображаемое количество с единицей
  String get displayAmount => '${amount.toStringAsFixed(1)} $unit';

  /// Получить отображаемые калории
  String get displayCalories => '$totalCalories ккал';

  ExerciseRecord copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    int? caloriesPerUnit,
    DateTime? timestamp,
    String? note,
  }) {
    return ExerciseRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      caloriesPerUnit: caloriesPerUnit ?? this.caloriesPerUnit,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'caloriesPerUnit': caloriesPerUnit,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      caloriesPerUnit: json['caloriesPerUnit'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    unit,
    caloriesPerUnit,
    timestamp,
    note,
  ];
}
