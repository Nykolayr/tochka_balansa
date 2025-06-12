import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tochka_balansa/main.dart';

class DioExceptions implements Exception {
  late String errorText;

  DioExceptions.fromDioError(DioException dioError) {
    Logger.e(
      ' dioError  ${dioError.requestOptions.method} ${dioError.requestOptions.uri} ${dioError.requestOptions.data}',
    );
    Logger.i(
      'DioExceptions.fromDioError dioError $dioError ${dioError.response?.statusCode}',
    );
    switch (dioError.type) {
      case DioExceptionType.cancel:
        errorText = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        errorText = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        errorText = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badCertificate:
        errorText = "Неправильный сертификат";
        break;
      case DioExceptionType.badResponse:
        errorText = handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        errorText = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
        if (dioError.message != null &&
            dioError.message!.contains("SocketException")) {
          errorText = 'No Internet';
          break;
        }
        errorText = "Unexpected error occurred";
        break;
      default:
        errorText =
            "path:  ${dioError.requestOptions.uri}  message:  ${dioError.message}";
        break;
    }

    Logger.e('Ошибка fromDioError  $errorText');

    // Показываем тостер с ошибкой
    _showErrorToast(errorText);
  }

  String handleError(int? statusCode, dynamic error) {
    Logger.e('Ошибка handleError statusCode $statusCode error $error');
    String errorText = 'Ошибка handleError statusCode $statusCode error $error';

    switch (statusCode) {
      case 400:
        if (error is Map) {
          if (error['code'] == 3) {
            errorText = 'Data is busy, try to select other days';
          } else {
            // Формируем сообщение из message и errors
            String message = error['message'] ?? 'Bad request';
            String errorsText = '';

            if (error['errors'] is Map) {
              Map<String, dynamic> errors = error['errors'];
              List<String> errorParts = [];

              errors.forEach((key, value) {
                if (value is List) {
                  errorParts.add('$key: ${value.join(', ')}');
                } else {
                  errorParts.add('$key: $value');
                }
              });

              if (errorParts.isNotEmpty) {
                errorsText = ' {${errorParts.join(', ')}}';
              }
            }

            errorText = message + errorsText;
          }
        } else {
          errorText = 'Bad request error 400';
        }
        break;
      case 401:
        errorText = 'Unauthorized error 401';
        // Проверяем сообщение об ошибке
        if (error is Map && error['error'] == 'not auth') {
          // Пропускаем рефреш токена для ошибки не авторизации
          break;
        }

        break;
      case 403:
        errorText = 'Forbidden error 403';
        if (error is Map) {
          if (error['message'] != null) {
            errorText = error['message'];
          } else if (error['error'] != null) {
            errorText = error['error'];
          }
        }
        break;
      case 404:
        errorText = 'ошибка 404, страница не найдена';
        break;
      case 422:
        if (error is Map && error['errors'] is Map) {
          final errors = error['errors'] as Map;
          final firstErrorKey = errors.keys.first;
          errorText = errors[firstErrorKey]?.first;
        } else {
          errorText = 'Unprocessable Entity error 422';
        }
        break;
      case 429:
        errorText = 'Too many requests error 429';
        break;
      case 500:
        errorText = 'Internal server error error 500';
      case 502:
        errorText = 'Bad gateway error 502';
      default:
        errorText = 'Oops something went wrong';
    }
    // Убираем автоматический показ диалога - пусть приложение само решает
    // showErrorDialog(errorText);
    return errorText;
  }

  @override
  String toString() => errorText;

  void _showErrorToast(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      FToast fToast = FToast();
      fToast.init(context);

      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.red,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
          ],
        ),
      );

      fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 4),
      );
    }
  }
}
