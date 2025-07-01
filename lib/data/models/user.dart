import 'package:equatable/equatable.dart';
import 'package:tochka_balansa/data/models/gender.dart';

/// Модель пользователя
class User extends Equatable {
  final int id;
  final String name;
  final DateTime birthDate;
  final String email;
  final Gender gender;
  final double initialWeight;
  final double height;

  bool get isReg => name.isNotEmpty;

  const User({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.email,
    required this.gender,
    required this.initialWeight,
    required this.height,
  });

  factory User.initial() => User(
    id: 0,
    name: '',
    birthDate: DateTime.now(),
    email: '',
    gender: Gender.female,
    initialWeight: 0.0,
    height: 0.0,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      birthDate: DateTime.tryParse(json['birth_date'] ?? '') ?? DateTime.now(),
      email: json['email'] ?? '',
      gender: Gender.values.firstWhere(
        (g) => g.toString() == 'Gender.${json['gender']}',
        orElse: () => Gender.female,
      ),
      initialWeight: (json['initial_weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'email': email,
      'gender': gender.name,
      'initial_weight': initialWeight,
      'height': height,
    };
  }

  User copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    String? email,
    Gender? gender,
    double? initialWeight,
    double? height,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,

      email: email ?? this.email,
      gender: gender ?? this.gender,
      initialWeight: initialWeight ?? this.initialWeight,
      height: height ?? this.height,
    );
  }

  /// возраст пользователя, вычисляется из даты рождения
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    birthDate,
    age,
    email,
    gender,
    initialWeight,
    height,
  ];
}
