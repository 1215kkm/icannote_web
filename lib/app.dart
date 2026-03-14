import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/settings_provider.dart';

class ICanNoteApp extends ConsumerWidget {
  const ICanNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final ThemeData theme;
    switch (settings.themeMode) {
      case AppThemeMode.light:
        theme = AppTheme.lightTheme;
        break;
      case AppThemeMode.dark:
        theme = AppTheme.darkTheme;
        break;
      case AppThemeMode.system:
        theme = AppTheme.darkTheme; // Default to dark
        break;
    }

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: theme,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      locale: Locale(settings.language.code),
      supportedLocales: AppLanguage.values
          .map((l) => Locale(l.code))
          .toList(),
    );
  }
}
