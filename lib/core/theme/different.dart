import 'package:flutter/material.dart';
import 'package:tochka_balansa/core/theme/theme.dart';

class AppDif {
  static const Divider divider = Divider(color: AppColor.grey, height: 1);
  static const Radius radius16 = Radius.circular(16);
  static const Radius radius28 = Radius.circular(28);
  static const Radius radius14 = Radius.circular(14);
  static const Radius radius12 = Radius.circular(12);
  static const Radius radius10 = Radius.circular(10);
  static const Radius radius8 = Radius.circular(8);
  static const Radius radius6 = Radius.circular(6);
  static const Radius radius3 = Radius.circular(3);

  static const BorderRadius borderRadius28 = BorderRadius.all(radius28);
  static const BorderRadius borderRadius16 = BorderRadius.all(radius16);
  static const BorderRadius borderRadius14 = BorderRadius.all(radius14);
  static const BorderRadius borderRadius12 = BorderRadius.all(radius12);
  static const BorderRadius borderRadius10 = BorderRadius.all(radius10);
  static const BorderRadius borderRadius8 = BorderRadius.all(radius8);
  static const BorderRadius borderRadius6 = BorderRadius.all(radius6);
  static const BorderRadius borderRadius3 = BorderRadius.all(radius3);

  static BoxShadow boxShadowMain = BoxShadow(
    color: AppColor.black.withAlpha(128), // Цвет тени
    spreadRadius: 0, // Радиус рассеивания
    blurRadius: 25, // Радиус размытия
    offset: const Offset(0, 4), // Смещение тени
  );
  static BoxShadow boxCard = BoxShadow(
    color: Colors.black.withAlpha(64), // 25% прозрачность
    blurRadius: 150, // Размытие
    offset: const Offset(0, 4), // Смещение по X и Y
  );

  /// общий для всех textField
  static InputDecoration getInputDecoration({
    required String hint,
    bool isTitle = false,
  }) {
    return InputDecoration(
      errorStyle: const TextStyle(fontSize: 10, height: 0.3),
      border: getOutlineBorder(),
      focusedBorder: getOutlineBorder(),
      enabledBorder: getOutlineBorder(),
      disabledBorder: getOutlineBorder(),
      errorBorder: getOutlineBorder(color: AppColor.red),
      focusedErrorBorder: getOutlineBorder(color: AppColor.red),
      filled: true,
      hintStyle: const TextStyle(color: AppColor.grey),
      hintText: hint,
      fillColor: AppColor.whitefon,
      contentPadding: isTitle
          ? null
          : const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    );
  }

  static OutlineInputBorder getOutlineBorder({
    Color color = AppColor.whitefon,
  }) {
    return OutlineInputBorder(
      borderRadius: AppDif.borderRadius16,
      borderSide: BorderSide(width: 1, style: BorderStyle.solid, color: color),
    );
  }
}
