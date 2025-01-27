import 'package:localbreeze/styles/color.dart';
import 'package:flutter/material.dart';

// Light Theme
final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    actionIconTheme: ActionIconThemeData(backButtonIconBuilder: (context) {
      return const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
      );
    }),
    primaryColor: AppColorsLight.backgroundColor,
    cardColor: AppColorsLight.blurColor,
    hintColor: AppColorsLight.headingTextColor,
    splashColor: AppColorsLight.inputBarColor,
    primaryColorLight: AppColorsLight.inputLabelColor);

// Dark Theme
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  actionIconTheme: ActionIconThemeData(backButtonIconBuilder: (context) {
    return const Icon(
      Icons.arrow_back_ios,
      color: Colors.white,
    );
  }),
  primaryColor: AppColorsDark.backgroundColor,
  cardColor: AppColorsDark.blurColor,
  hintColor: AppColorsDark.headingTextColor,
  splashColor: AppColorsDark.inputBarColor,
  primaryColorLight: AppColorsDark.inputLabelColor,
);
