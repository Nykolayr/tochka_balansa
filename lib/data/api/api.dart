import 'package:get/get.dart';
import 'package:tochka_balansa/data/api/dio_client.dart';
import 'package:tochka_balansa/data/models/response_api.dart';

class Api {
  final DioClient dio = Get.find<DioClient>();

  /// рефреш токена
  Future<ResponseApi> refreshToken() async {
    return await dio.post('/api/mobile/refresh');
  }

  /// авторизация по email
  Future<ResponseApi> authEmail(String email, String password) async {
    return await dio.post(
      '/api/mobile/auth/email',
      data: {'email': email, 'password': password},
    );
  }

  /// регистрация по email
  Future<ResponseApi> regEmail(String email, String password) async {
    return await dio.post(
      '/api/mobile/reg/email',
      data: {'email': email, 'password': password},
    );
  }

  /// проверка кода
  Future<ResponseApi> checkCode(String email, String code) async {
    return await dio.post(
      '/api/mobile/check/code',
      data: {'email': email, 'code': code},
    );
  }

  /// удаление аккаунта
  Future<ResponseApi> deleteAccount() async {
    return await dio.post('/api/mobile/delete/account');
  }

  /// получить изера
  Future<ResponseApi> getUser() async {
    return await dio.get('/api/mobile/user');
  }
}
