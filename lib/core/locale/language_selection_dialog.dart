import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import 'locale_cubit.dart';

void showLanguageSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      final currentLocale = ctx.read<LocaleCubit>().state.languageCode;

      return AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          l10n.changeLanguage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocaleCubit.supportedLocales.map((code) {
              final name = LocaleCubit.getLanguageName(code);
              final isSelected = currentLocale == code;

              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.greenAccent : Colors.white54,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.greenAccent : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  ctx.read<LocaleCubit>().setLocale(Locale(code));
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      );
    },
  );
}
