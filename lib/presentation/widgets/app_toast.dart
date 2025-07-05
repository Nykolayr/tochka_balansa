import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tochka_balansa/core/theme/colors.dart';

class AppToast {
  /// Показать toast уведомление
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColor.darkBlue,
      textColor: AppColor.white,
      fontSize: 16.0,
    );
  }

  /// Скрыть все toast уведомления
  static void cancel() {
    Fluttertoast.cancel();
  }
}
