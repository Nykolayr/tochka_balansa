import 'package:dio/dio.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tochka_balansa/core/constants/api_constans.dart';
import 'package:tochka_balansa/data/api/dio_exception.dart';
import 'package:tochka_balansa/data/datasources/secure_storage_servis.dart';
import 'package:tochka_balansa/data/models/response_api.dart';
import 'package:tochka_balansa/data/repositories/user_repository.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio
      ..options.baseUrl = serverPath
      ..options.connectTimeout = const Duration(seconds: 35)
      ..options.receiveTimeout = const Duration(seconds: 35);
  }

  Future<Options> getOptions() async {
    // Получаем Device ID

    final token = await SecureStorageService().getToken() ?? '';
    // Базовые заголовки
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'X-USER-TOKEN': token,
    };

    // Добавляем токен только если он есть
    if (Get.isRegistered<UserRepository>() &&
        Get.find<UserRepository>().isReg &&
        Get.find<UserRepository>().token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${Get.find<UserRepository>().token}';
      headers['X-USER-TOKEN'] = Get.find<UserRepository>().token;
    }

    return Options(headers: headers);
  }

  Future<ResponseApi> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool isExtended = true,
  }) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: await getOptions(),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return processResponse(response.data, url, isExtended: isExtended);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        url,
        data: data,
        options: await getOptions(),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> put(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: await getOptions(),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: await getOptions(),
        cancelToken: cancelToken,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }
}

ResponseApi errorHandling(Object e) {
  if (e is DioException) {
    DioExceptions dioException = DioExceptions.fromDioError(e);
    return ResError(errorMessage: dioException.errorText);
  } else {
    return ResError(errorMessage: 'Unexpected error occurred: ${e.toString()}');
  }
}

ResponseApi processResponse(
  dynamic res,
  String path, {
  bool isExtended = true,
}) {
  if (isExtended || res['success'] == true) {
    late ResSuccess resSuccess;
    if (isExtended) {
      resSuccess = ResSuccess(res);
    } else {
      resSuccess = ResSuccess(res['base']);
    }
    resSuccess.consoleRes(path);
    return resSuccess;
  } else {
    if (res['error'] != null) {
      if (res['error']['error'] == null) {
        return ResError(errorMessage: res['error']);
      } else {
        final firstError = res['error']['error'].values.first[0];
        return ResError(errorMessage: firstError);
      }
    }
    return ResError(errorMessage: 'Ошибка сервера');
  }
}
