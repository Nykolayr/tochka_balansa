import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Supplement extends Equatable {
  final String name;
  final String dosage; // например: "1000 МЕ", "500 мг"
  final TimeOfDay timeToTake; // время приема
  final int quantityInPackage; // количество в упаковке
  final String frequency; // частота приема: "ежедневно", "2 раза в день"
  final String instructions; // инструкции по применению
  final bool isActive;

  const Supplement({
    required this.name,
    required this.dosage,
    required this.timeToTake,
    required this.quantityInPackage,
    required this.frequency,
    this.instructions = '',
    this.isActive = true,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    final timeStr = json['timeToTake'] as String;
    final timeParts = timeStr.split(':');
    final timeToTake = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return Supplement(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      timeToTake: timeToTake,
      quantityInPackage: json['quantityInPackage'] ?? 0,
      frequency: json['frequency'] ?? '',
      instructions: json['instructions'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'timeToTake':
          '${timeToTake.hour.toString().padLeft(2, '0')}:${timeToTake.minute.toString().padLeft(2, '0')}',
      'quantityInPackage': quantityInPackage,
      'frequency': frequency,
      'instructions': instructions,
      'isActive': isActive,
    };
  }

  Supplement copyWith({
    String? name,
    String? dosage,
    TimeOfDay? timeToTake,
    int? quantityInPackage,
    String? frequency,
    String? instructions,
    bool? isActive,
  }) {
    return Supplement(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timeToTake: timeToTake ?? this.timeToTake,
      quantityInPackage: quantityInPackage ?? this.quantityInPackage,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    name,
    dosage,
    timeToTake,
    quantityInPackage,
    frequency,
    instructions,
    isActive,
  ];

  @override
  String toString() {
    return 'Supplement(name: $name, dosage: $dosage, frequency: $frequency)';
  }
}
