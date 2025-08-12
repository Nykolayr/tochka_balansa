import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/data/api/api.dart';
import 'package:tochka_balansa/data/api/dio_client.dart';
import 'package:tochka_balansa/data/repositories/main_repository.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';
import 'package:tochka_balansa/data/repositories/health_repository.dart';
import 'package:tochka_balansa/data/repositories/daily_calories_repository.dart';
import 'package:tochka_balansa/presentation/pages/auth/bloc/auth_bloc.dart';
import 'package:tochka_balansa/presentation/pages/food/bloc/food_bloc.dart';
import 'package:tochka_balansa/presentation/pages/goal/bloc/goal_bloc.dart';
import 'package:tochka_balansa/presentation/pages/main/bloc/main_bloc.dart';
import 'package:tochka_balansa/presentation/pages/health/bloc/health_bloc.dart';
import 'package:tochka_balansa/providers/language_bloc.dart';

/// внедряем зависимости
Future<void> initMain() async {
  await Get.putAsync(() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  });

  try {
    await Get.putAsync<DioClient>(() async => DioClient(Dio()));
    await Get.putAsync<Api>(() async => Api());
  } catch (e) {
    Logger.e('DioClient error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    await Get.putAsync(() async {
      final userRepository = UserRepository();
      await userRepository.init();
      return userRepository;
    });
  } catch (e) {
    Logger.e('UserRepository error = $e');
    // Убираем return, просто логируем ошибку
  }

  // Регистрируем HealthRepository
  try {
    await Get.putAsync(() async {
      final healthRepository = HealthRepository();
      return healthRepository;
    });
  } catch (e) {
    Logger.e('HealthRepository error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    Get.put<AuthBloc>(AuthBloc());
  } catch (e) {
    Logger.e('AuthBloc error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    await Get.putAsync(() async {
      final mainRepository = MainRepository();
      return mainRepository;
    });
  } catch (e) {
    Logger.e('MainRepository error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    await Get.find<MainRepository>().init();
  } catch (e) {
    Logger.e('MainRepository error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    Get.put<MainBloc>(MainBloc());
  } catch (e) {
    Logger.e('MainBloc error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    Get.put<GoalBloc>(GoalBloc());
  } catch (e) {
    Logger.e('GoalBloc error = $e');
    // Убираем return, просто логируем ошибку
  }

  try {
    Get.put<FoodBloc>(FoodBloc());
  } catch (e) {
    Logger.e('FoodBloc error = $e');
    // Убираем return, просто логируем ошибку
  }

  // Добавляем LanguageBloc
  try {
    Get.put<LanguageBloc>(LanguageBloc());
  } catch (e) {
    Logger.e('LanguageBloc error = $e');
    // Убираем return, просто логируем ошибку
  }

  // Добавляем HealthBloc
  try {
    Get.put<HealthBloc>(HealthBloc());
  } catch (e) {
    Logger.e('HealthBloc error = $e');
    // Убираем return, просто логируем ошибку
  }

  // Инициализируем репозиторий калорий
  try {
    final dailyCaloriesRepo = DailyCaloriesRepository();
    Get.put(dailyCaloriesRepo);

    // Сразу создаем запись на сегодня с рассчитанными калориями
    final todayRecord = await dailyCaloriesRepo.getOrCreateTodayRecord();

    Logger.i('Создана запись на сегодня:');
    Logger.i('- Съедено: ${todayRecord.consumedCalories}');
    Logger.i('- Сожжено: ${todayRecord.burnedCalories}');
    Logger.i('- Максимум: ${todayRecord.maxCalories}');

    // Получаем созданную запись и обновляем MainBloc
    final mainBloc = Get.find<MainBloc>();
    mainBloc.add(
      UpdateCaloriesEvent(
        consumedCalories: todayRecord.consumedCalories, // 0
        burnedCalories: todayRecord
            .burnedCalories, // Рассчитанные калории (BMR + активность)
        maxCalories: todayRecord.maxCalories, // Максимум для сосудов
      ),
    );
  } catch (e) {
    Logger.e('DailyCaloriesRepository error = $e');
    // Убираем return, просто логируем ошибку
  }

  await Future.delayed(Duration(seconds: 2));
  // Убираем return '', функция должна возвращать void
}
