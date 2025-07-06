import 'package:tochka_balansa/data/models/goal/additional_goal.dart';

/// Цель по приёму мед. препаратов
class SupplementGoal extends AdditionalGoal {
  final String supplementName;
  final String dosage;

  SupplementGoal({
    required this.supplementName,
    required this.dosage,
    required super.reminders,
    String? id,
    String? title,
    String? description,
    bool? isActive,
  }) : super(
         id: id ?? 'supplement_${supplementName.toLowerCase()}',
         title: title ?? 'Приём $supplementName',
         description: description ?? 'Дозировка: $dosage',
         isActive: isActive ?? true,
       );

  factory SupplementGoal.init() {
    return SupplementGoal(
      supplementName: 'Витамин D',
      dosage: '1000 МЕ',
      reminders: const [],
    );
  }

  factory SupplementGoal.fromJson(Map<String, dynamic> json) {
    final reminders =
        (json['reminders'] as List<dynamic>?)
            ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SupplementGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      supplementName: json['name'] ?? 'Витамин D',
      dosage: json['dosage'] ?? '1000 МЕ',
      reminders: reminders,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'supplement',
    'id': id,
    'title': title,
    'description': description,
    'isActive': isActive,
    'name': supplementName,
    'dosage': dosage,
    'reminders': reminders.map((r) => r.toJson()).toList(),
  };

  @override
  SupplementGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    List<Reminder>? reminders,
    String? supplementName,
    String? dosage,
  }) {
    return SupplementGoal(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
      reminders: reminders ?? this.reminders,
      supplementName: supplementName ?? this.supplementName,
      dosage: dosage ?? this.dosage,
    );
  }

  @override
  List<Object?> get props => [...super.props, supplementName, dosage];
}
