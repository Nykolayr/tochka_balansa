import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/data/api/api.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/datasources/secure_storage_servis.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/response_api.dart';
import 'package:tochka_balansa/data/models/user.dart';
import 'package:tochka_balansa/data/models/goal/additional_goal.dart';

/// репо для юзера
class UserRepository {
  String token = '';
  User user = User.initial();
  List<AdditionalGoal> goalTypes = []; // Убираем геттер/сеттер

  bool get isReg => token.isNotEmpty;

  static final UserRepository _instance = UserRepository._internal();

  UserRepository._internal();

  factory UserRepository() => _instance;

  /// удаление пользователя
  Future<bool> deleteUser() async {
    return false;
  }

  /// сохранение данных пользователя
  Future<void> saveUserData(
    String name,
    double weight,
    double height,
    DateTime birthDate,
    Gender gender,
  ) async {
    user = user.copyWith(
      name: name,
      initialWeight: weight,
      height: height,
      birthDate: birthDate,
      gender: gender,
    );
    await saveUserToLocal();
  }

  /// сохранение языка пользователя
  Future<void> saveUserLanguage(LanguageEnum language) async {
    user = user.copyWith(language: language.code);
    await saveUserToLocal();
  }

  /// Начальная загрузка пользователя из локального хранилища
  Future<void> init() async {
    try {
      Logger.i('Инициализация UserRepository');
      await HiveData.init();
      token = await SecureStorageService().getToken() ?? '';
      Logger.i(
        'Токен загружен: ${token.isNotEmpty ? "присутствует" : "отсутствует"}',
      );
      await loadUserFromLocal();
    } catch (e) {
      Logger.e('Ошибка при инициализации UserRepository: $e');
    }
  }

  Future<void> logout() async {
    await HiveData.saveJson(
      json: User.initial().toJson(),
      key: HiveDataKey.user,
    );
    await SecureStorageService().deleteToken();
    user = User.initial();
    token = '';
  }

  /// удаление аккаунта
  Future<void> deleteAccount() async {
    await Api().deleteAccount();
    await logout();
  }

  /// авторизация по email
  Future<String> authEmail({
    required String email,
    required String password,
  }) async {
    final answer = await Api().authEmail(email, password);
    if (answer is ResSuccess) {
      if (answer.data['data'] != null && answer.data['data']['token'] != null) {
        token = answer.data['data']['token'];

        await SecureStorageService().saveToken(token);
      }
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// регистрация по email
  Future<String> regEmail({
    required String email,
    required String password,
  }) async {
    final answer = await Api().regEmail(email, password);
    if (answer is ResSuccess) {
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// подтверждение кода
  Future<String> checkCode({
    required String email,
    required String code,
  }) async {
    final answer = await Api().checkCode(email, code);
    if (answer is ResSuccess) {
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// получить изера
  Future<String> getUser() async {
    Logger.i('getUser token >>>>> $token');

    // Сохраняем текущие локальные цели перед получением данных с сервера
    final localMainGoal = user.mainGoal;
    final localAdditionalGoals = user.additionalGoals;
    Logger.i('Сохранены локальные цели: mainGoal = $localMainGoal');

    final response = await Api().getUser();
    if (response is ResSuccess) {
      // Создаем пользователя из данных сервера
      final serverUser = User.fromJson(response.data);
      Logger.i(
        'Получен пользователь с сервера: mainGoal = ${serverUser.mainGoal}',
      );

      // Объединяем данные: берем основные данные с сервера, но сохраняем локальные цели
      user = serverUser.copyWith(
        mainGoal: localMainGoal.hasMainGoal
            ? localMainGoal
            : serverUser.mainGoal,
        additionalGoals: localAdditionalGoals.isNotEmpty
            ? localAdditionalGoals
            : serverUser.additionalGoals,
      );

      Logger.i('Объединенный пользователь: mainGoal = ${user.mainGoal}');
      saveUserToLocal();
      return '';
    } else if (response is ResError) {
      Logger.e('error getUser ${response.errorMessage}');
      return response.errorMessage;
    }
    return '';
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await HiveData.saveJson(
      json: User.initial().toJson(),
      key: HiveDataKey.user,
    );
    await SecureStorageService().deleteToken();
    user = User.initial();
    token = '';
  }

  /// Загрузка пользователя из локального хранилища
  Future<void> loadUserFromLocal() async {
    try {
      final data = await HiveData.loadJson(key: HiveDataKey.user);
      Logger.e('loadUserFromLocal $data');

      // Проверяем, есть ли поле error
      if (data.containsKey('error')) {
        Logger.e('User data contains error: ${data['error']}');
        // Если есть ошибка, оставляем user как есть (User.initial())
        return;
      }

      // Дополнительная диагностика mainGoal
      if (data.containsKey('mainGoal')) {
        final mainGoalData = data['mainGoal'];
        Logger.i('Найдена mainGoal в данных: $mainGoalData');
        Logger.i('Тип mainGoal: ${mainGoalData.runtimeType}');
        if (mainGoalData is Map) {
          Logger.i(
            'mainGoal является Map с ключами: ${mainGoalData.keys.toList()}',
          );
          if (mainGoalData.containsKey('goalType')) {
            Logger.i('goalType в mainGoal: ${mainGoalData['goalType']}');
          }
        }
      } else {
        Logger.e('mainGoal отсутствует в данных пользователя');
      }

      // Сохраняем текущие цели перед загрузкой
      final currentMainGoal = user.mainGoal;

      // Загружаем пользователя из Hive
      final loadedUser = User.fromJson(data);
      Logger.i(
        'Загружен пользователь из Hive: ${loadedUser.name}, mainGoal: ${loadedUser.mainGoal}',
      );

      // Если у загруженного пользователя нет цели, но у текущего есть - сохраняем текущую
      if (!loadedUser.mainGoal.hasMainGoal && currentMainGoal.hasMainGoal) {
        Logger.i('Сохраняем текущую цель, так как загруженная цель пустая');
        user = loadedUser.copyWith(mainGoal: currentMainGoal);
      } else {
        user = loadedUser;
      }

      Logger.i(
        'Итоговый пользователь: ${user.name}, mainGoal: ${user.mainGoal}',
      );
    } catch (e) {
      Logger.e('user error $e');
    }
  }

  /// Сохранение пользователя в локальное хранилище
  Future<void> saveUserToLocal() async {
    final json = user.toJson();
    Logger.i(
      'Сохранение пользователя в Hive: ${user.name}, mainGoal: ${user.mainGoal}',
    );

    // Проверяем, что mainGoal корректно сериализуется
    if (json.containsKey('mainGoal')) {
      Logger.i('mainGoal в JSON: ${json['mainGoal']}');
    } else {
      Logger.e('mainGoal отсутствует в JSON при сохранении');
    }

    await HiveData.saveJson(json: json, key: HiveDataKey.user);
    Logger.i('Пользователь сохранен в Hive');
  }

  Future<void> saveGoalTypesToLocal() async {
    try {
      final goalTypesJson = goalTypes.map((goal) => goal.toJson()).toList();
      await HiveData.saveListJson(
        json: goalTypesJson,
        key: HiveDataKey.goalTypes,
      );
      Logger.i('Типы целей сохранены в Hive');
    } catch (e) {
      Logger.e('Ошибка сохранения типов целей: $e');
    }
  }

  Future<void> loadGoalTypesFromLocal() async {
    try {
      final goalTypesJson = await HiveData.loadListJson(
        key: HiveDataKey.goalTypes,
      );
      goalTypes = goalTypesJson
          .map((json) => AdditionalGoal.fromJson(json))
          .toList();
      Logger.i('Типы целей загружены из Hive: ${goalTypes.length}');
    } catch (e) {
      Logger.e('Ошибка загрузки типов целей: $e');
      goalTypes = [];
    }
  }
}
