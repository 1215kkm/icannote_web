import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.themeSurface,
        ),
        scaffoldBackgroundColor: AppColors.themeScaffold,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.themeAppBar,
          elevation: 0,
        ),
        useMaterial3: true,
      );
}
