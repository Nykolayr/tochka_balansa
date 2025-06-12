import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

Future<void> setupDependencies() async {
  // Хранилище токенов
  Get.put<FlutterSecureStorage>(const FlutterSecureStorage(), permanent: true);

  // Dio с интерцептором для токена
  Get.put<Dio>(
    Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await Get.find<FlutterSecureStorage>().read(
              key: 'token',
            );
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
        ),
      ),
    permanent: true,
  );
}
