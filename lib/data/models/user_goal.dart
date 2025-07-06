import 'package:equatable/equatable.dart';

class UserGoal extends Equatable {
  final String id;
  final String title;
  final String description;
  final double targetWeight;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;

  const UserGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetWeight,
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });

  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetWeight: json['targetWeight'],
      targetDate: json['targetDate'],
      createdAt: json['createdAt'],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetWeight': targetWeight,
      'targetDate': targetDate,
      'createdAt': createdAt,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
    };
  }

  UserGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetWeight,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return UserGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory UserGoal.init() => UserGoal(
    id: '',
    title: '',
    description: '',
    targetWeight: 0,
    targetDate: DateTime.now(),
    createdAt: DateTime.now(),
  );

  // Методы для удобства
  UserGoal markAsCompleted() {
    return copyWith(isCompleted: true, completedAt: DateTime.now());
  }

  UserGoal markAsIncomplete() {
    return copyWith(isCompleted: false, completedAt: null);
  }

  // Геттеры для вычисляемых свойств
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);

  int get daysUntilTarget {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  double get progressPercentage {
    if (isCompleted) return 100.0;
    // Здесь можно добавить логику расчета прогресса
    // Например, на основе текущего веса vs целевого веса
    return 0.0; // Пока возвращаем 0, логику добавим позже
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    targetWeight,
    targetDate,
    createdAt,
    isCompleted,
    completedAt,
  ];

  @override
  String toString() {
    return 'UserGoal(id: $id, title: $title, targetWeight: $targetWeight, isCompleted: $isCompleted)';
  }
}
