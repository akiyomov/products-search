// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> ko_KO = {
  "open_scan": "스케이너 열기",
  "info_text": "제품보이콧정보확인",
  "current_lang": "English"
};
static const Map<String,dynamic> en_US = {
  "open_scan": "Open Scanner",
  "info_text": "Check Product’s Boycott Information",
  "current_lang": "Korean"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ko_KO": ko_KO, "en_US": en_US};
}
