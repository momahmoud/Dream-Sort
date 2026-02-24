import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'locale';

  LocaleCubit() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final box = Hive.box('game_data');
    final savedLocale = box.get(_localeKey, defaultValue: 'ar') as String;
    emit(Locale(savedLocale));
  }

  void setLocale(Locale locale) {
    _saveLocale(locale.languageCode);
    emit(locale);
  }

  static const List<String> supportedLocales = ['en', 'ar', 'es', 'fr', 'hi'];

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية (Arabic)';
      case 'es':
        return 'Español (Spanish)';
      case 'fr':
        return 'Français (French)';
      case 'hi':
        return 'हिंदी (Hindi)';
      default:
        return languageCode.toUpperCase();
    }
  }

  void toggleLocale() {
    final currentIndex = supportedLocales.indexOf(state.languageCode);
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    final nextLocaleCode = supportedLocales[nextIndex];

    _saveLocale(nextLocaleCode);
    emit(Locale(nextLocaleCode));
  }

  void _saveLocale(String languageCode) {
    final box = Hive.box('game_data');
    box.put(_localeKey, languageCode);
  }
}
