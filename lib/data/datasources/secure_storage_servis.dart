import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Сохранение токена
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Получение токена
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Удаление токена
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
