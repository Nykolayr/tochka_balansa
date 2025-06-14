import 'package:equatable/equatable.dart';

/// Модель слайда для онбординга
class SlideModel extends Equatable {
  final String title;
  final String description;
  final String image;
  final String titleEn;
  final String descriptionEn;

  const SlideModel({
    required this.title,
    required this.description,
    required this.image,
    required this.titleEn,
    required this.descriptionEn,
  });

  /// Создает модель из JSON
  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      titleEn: json['title_en'] as String,
      descriptionEn: json['description_en'] as String,
    );
  }

  /// Преобразует модель в JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'title_en': titleEn,
      'description_en': descriptionEn,
    };
  }

  /// Создает копию модели с возможностью изменения полей
  SlideModel copyWith({
    String? title,
    String? description,
    String? image,
    String? titleEn,
    String? descriptionEn,
  }) {
    return SlideModel(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      titleEn: titleEn ?? this.titleEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    image,
    titleEn,
    descriptionEn,
  ];
}
