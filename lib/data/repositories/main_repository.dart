import 'dart:async';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/api/api.dart';
import 'package:tochka_balansa/data/mock/slides_mock.dart';
import 'package:tochka_balansa/data/models/slide_model.dart';

/// репо для всего приложения
class MainRepository extends GetxController {
  static final MainRepository _instance = MainRepository._internal();

  MainRepository._internal();

  factory MainRepository() => _instance;
  final Api api = Get.find<Api>();

  /// Список слайдов для онбординга
  List<SlideModel> slides = [];

  /// Начальная загрузка
  Future init() async {
    await getSlides();
  }

  /// Получение списка слайдов для онбординга
  Future<void> getSlides() async {
    // TODO: В будущем здесь будет запрос к API
    // Пока используем моковые данные
    try {
      // Имитируем задержку сети
      await Future.delayed(const Duration(milliseconds: 500));
      // Парсим JSON в модели
      slides = SlidesMock.slidesJson
          .map((json) => SlideModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.e('Ошибка getSlides $e');
    }
  }
}
