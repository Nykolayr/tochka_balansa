import 'package:equatable/equatable.dart';

class Drug extends Equatable {
  final String id;
  final String barcode;
  final String name;
  final String? description;
  final int totalQuantity;
  final String quantityUnit; // таблетки, капсулы, мл, граммы и т.д.
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Drug({
    required this.id,
    required this.barcode,
    required this.name,
    this.description,
    required this.totalQuantity,
    required this.quantityUnit,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'totalQuantity': totalQuantity,
      'quantityUnit': quantityUnit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalQuantity: json['totalQuantity'] as int,
      quantityUnit: json['quantityUnit'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Drug copyWith({
    String? id,
    String? barcode,
    String? name,
    String? description,
    int? totalQuantity,
    String? quantityUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Drug(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    barcode,
    name,
    description,
    totalQuantity,
    quantityUnit,
    createdAt,
    updatedAt,
  ];
}
