import 'package:tochka_balansa/utils/langs.dart';

bool isEnglish = false;

String textLang(String text) {
  if (isEnglish) {
    return rusLang[text] ?? text;
  }
  return text;
}

void toggleLanguage() {
  isEnglish = !isEnglish;
}
