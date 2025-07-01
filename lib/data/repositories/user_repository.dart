import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:tochka_balansa/data/api/api.dart';
import 'package:tochka_balansa/data/datasources/hive_data.dart';
import 'package:tochka_balansa/data/datasources/secure_storage_servis.dart';
import 'package:tochka_balansa/data/models/gender.dart';
import 'package:tochka_balansa/data/models/response_api.dart';
import 'package:tochka_balansa/data/models/user.dart';

/// репо для юзера
class UserRepository {
  String token = '';
  User user = User.initial();

  bool get isReg => token.isNotEmpty;

  static final UserRepository _instance = UserRepository._internal();

  UserRepository._internal();

  factory UserRepository() => _instance;

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

  /// Начальная загрузка пользователя из локального хранилища
  Future init() async {
    await HiveData.init();
    token = await SecureStorageService().getToken() ?? '';
    await loadUserFromLocal();
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
    final response = await Api().getUser();
    if (response is ResSuccess) {
      user = User.fromJson(response.data);
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
      if (data['error'] == null) {
        user = User.fromJson(data);
      } else {
        await saveUserToLocal();
      }
    } catch (e) {
      Logger.e('user error $e');
      try {
        await saveUserToLocal();
      } catch (e) {
        Logger.e('saveUserToLocal error $e');
      }
    }
  }

  /// Сохранение пользователя в локальное хранилище
  Future<void> saveUserToLocal() async {
    await HiveData.saveJson(json: user.toJson(), key: HiveDataKey.user);
  }
}
