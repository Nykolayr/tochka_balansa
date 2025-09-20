import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/api/api.dart';
import 'package:tochka_balansa/data/api/dio_client.dart';
import 'package:tochka_balansa/data/repositories/food_product_repository.dart';
// Удален import LocalProductRepository - объединен с FoodProductRepository
import 'package:tochka_balansa/data/repositories/main_repository.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/repositories/health_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_events_repository.dart';
import 'package:tochka_balansa/presentation/pages/auth/bloc/auth_bloc.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/presentation/pages/home/date_navigation_controller.dart';

/// внедряем зависимости
Future<void> initMain() async {
  // Инициализируем единый FoodProductRepository (объединили LocalProductRepository)
  try {
    await Get.putAsync<FoodProductRepository>(() async {
      final repo = FoodProductRepository();
      await repo.init();
      return repo;
    });
  } catch (e) {
    Logger.e('FoodProductRepository error = $e');
  }

  // Инициализируем PackageInfo
  await Get.putAsync(() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  });

  // Инициализируем DioClient и Api
  try {
    await Get.putAsync<DioClient>(() async => DioClient(Dio()));
    await Get.putAsync<Api>(() async => Api());
  } catch (e) {
    Logger.e('DioClient error = $e');
  }

  // Инициализируем UserRepository
  try {
    await Get.putAsync<UserRepository>(() async {
      final repo = UserRepository();
      await repo.init();
      return repo;
    });
  } catch (e) {
    Logger.e('UserRepository error = $e');
  }

  // Инициализируем DailyCaloriesRepository
  try {
    await Get.putAsync<DailyCaloriesRepository>(() async {
      final repo = DailyCaloriesRepository();
      await repo.init();
      return repo;
    });
    Logger.i('DailyCaloriesRepository инициализирован');
  } catch (e) {
    Logger.e('DailyCaloriesRepository error = $e');
  }

  // Инициализируем DailyEventsRepository
  try {
    await Get.putAsync<DailyEventsRepository>(() async {
      final repo = DailyEventsRepository();
      await repo.init();
      return repo;
    });
    Logger.i('DailyEventsRepository инициализирован');
  } catch (e) {
    Logger.e('DailyEventsRepository error = $e');
  }

  // Регистрируем HealthRepository
  try {
    await Get.putAsync<HealthRepository>(() async => HealthRepository());
  } catch (e) {
    Logger.e('HealthRepository error = $e');
  }

  // Инициализируем AuthBloc
  try {
    await Get.putAsync<AuthBloc>(() async => AuthBloc());
  } catch (e) {
    Logger.e('AuthBloc error = $e');
  }

  // Инициализируем MainRepository
  try {
    await Get.putAsync<MainRepository>(() async {
      final repo = MainRepository();
      await repo.init();
      return repo;
    });
  } catch (e) {
    Logger.e('MainRepository error = $e');
  }

  // Инициализируем MainBloc
  try {
    await Get.putAsync<MainBloc>(() async => MainBloc());
  } catch (e) {
    Logger.e('MainBloc error = $e');
  }

  // Инициализируем GoalBloc
  try {
    await Get.putAsync<GoalBloc>(() async => GoalBloc());
  } catch (e) {
    Logger.e('GoalBloc error = $e');
  }

  // Добавляем FoodBloc для работы с продуктами
  try {
    await Get.putAsync<FoodBloc>(() async => FoodBloc());
  } catch (e) {
    Logger.e('FoodBloc error = $e');
  }

  // Добавляем HealthBloc
  try {
    await Get.putAsync<HealthBloc>(() async => HealthBloc());
  } catch (e) {
    Logger.e('HealthBloc error = $e');
  }

  // Инициализируем контроллер навигации по датам
  try {
    Get.put(DateNavigationController());
    Logger.i('DateNavigationController инициализирован');
  } catch (e) {
    Logger.e('DateNavigationController error = $e');
  }

  Logger.i('Все блоки инициализированы и готовы к работе');

  Logger.w('end Locator');
}
