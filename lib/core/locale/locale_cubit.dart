import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'locale';

  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final box = Hive.box('game_data');
    final savedLocale = box.get(_localeKey, defaultValue: 'en') as String;
    emit(Locale(savedLocale));
  }

  void setLocale(Locale locale) {
    _saveLocale(locale.languageCode);
    emit(locale);
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      _saveLocale('ar');
      emit(const Locale('ar'));
    } else {
      _saveLocale('en');
      emit(const Locale('en'));
    }
  }

  void _saveLocale(String languageCode) {
    final box = Hive.box('game_data');
    box.put(_localeKey, languageCode);
  }
}
