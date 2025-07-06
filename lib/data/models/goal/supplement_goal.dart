import 'package:tochka_balansa/data/models/goal/additional_goal.dart';
import 'package:tochka_balansa/data/models/goal/enums_goal.dart';
import 'package:tochka_balansa/data/models/goal/supplement.dart';

/// Цель по приему добавок/лекарств
class SupplementGoal extends AdditionalGoal {
  final List<Supplement> supplements;

  const SupplementGoal({
    required this.supplements,
    required super.reminders,
    required super.deadlineType,
    super.targetDate,
    String? id,
    String? title,
    String? description,
    bool? isActive,
  }) : super(
         id: id ?? 'supplement_goal',
         title: title ?? 'Приём добавок',
         description: description ?? '${supplements.length} добавок',
         isActive: isActive ?? true,
       );

  factory SupplementGoal.init() {
    return SupplementGoal(
      supplements: const [],
      reminders: const [],
      deadlineType: DeadlineType.fixed,
    );
  }

  factory SupplementGoal.fromJson(Map<String, dynamic> json) {
    final reminders =
        (json['reminders'] as List<dynamic>?)
            ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final supplementsJson = json['supplements'] as List<dynamic>? ?? [];
    final supplements = supplementsJson
        .map((e) => Supplement.fromJson(e as Map<String, dynamic>))
        .toList();

    return SupplementGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      supplements: supplements,
      reminders: reminders,
      deadlineType: DeadlineType.values.firstWhere(
        (e) => e.name == json['deadlineType'],
        orElse: () => DeadlineType.fixed,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'supplement',
    'id': id,
    'title': title,
    'description': description,
    'isActive': isActive,
    'supplements': supplements.map((s) => s.toJson()).toList(),
    'reminders': reminders.map((r) => r.toJson()).toList(),
    'deadlineType': deadlineType.name,
    'targetDate': targetDate?.toIso8601String(),
  };

  @override
  SupplementGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    List<Reminder>? reminders,
    List<Supplement>? supplements,
    DeadlineType? deadlineType,
    DateTime? targetDate,
  }) {
    return SupplementGoal(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      reminders: reminders ?? this.reminders,
      supplements: supplements ?? this.supplements,
      deadlineType: deadlineType ?? this.deadlineType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  double get progressPercentage {
    if (deadlineType == DeadlineType.flexible) return 0.0;

    // TODO: Реализовать логику подсчета принятых добавок
    // Пока возвращаем заглушку
    return 0.0;
  }

  @override
  List<Object?> get props => [...super.props, supplements];
}
