import 'dart:async';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/api/api.dart';

/// репо для всего приложения
class MainRepository extends GetxController {
  static final MainRepository _instance = MainRepository._internal();

  MainRepository._internal();

  factory MainRepository() => _instance;

  final Api api = Get.find<Api>();

  /// Начальная загрузка
  Future init() async {}
}
