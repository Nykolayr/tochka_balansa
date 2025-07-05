import 'package:equatable/equatable.dart';

/// Модель слайда для онбординга
class SlideModel extends Equatable {
  final String title;
  final String description;
  final String image;

  const SlideModel({
    required this.title,
    required this.description,
    required this.image,
  });

  /// Создает модель из JSON
  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
    );
  }

  /// Преобразует модель в JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'image': image};
  }

  /// Создает копию модели с возможностью изменения полей
  SlideModel copyWith({String? title, String? description, String? image}) {
    return SlideModel(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [title, description, image];
}
