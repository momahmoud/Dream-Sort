import 'package:dream_sort/core/locale/locale_cubit.dart';
import 'package:dream_sort/core/theme/app_theme.dart';
import 'package:dream_sort/features/game/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

class DreamSortApp extends StatelessWidget {
  const DreamSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          title: 'Dream Sort',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(locale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('es'),
            Locale('fr'),
            Locale('hi'),
          ],
          locale: locale,
          home: const HomePage(),
        );
      },
    );
  }
}
