import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localbreeze/providers/theme_provider.dart';

Map<int, String> weatherIconsLight = {
  1000: 'assets/icons/light/clear.png', // Clear/Sunny
  1003: 'assets/icons/light/sunny.png', // Partly Cloudy
  1006: 'assets/icons/light/cloudy.png', // Cloudy
  1009: 'assets/icons/light/sunny.png', // Overcast
  1030: 'assets/icons/light/sunny.png', // Mist
  1063: 'assets/icons/light/rain.png', // Patchy rain possible
  1066: 'assets/icons/light/cloudyandrain.png', // Patchy snow possible
  1069: 'assets/icons/light/rain.png', // Patchy sleet possible
  1072: 'assets/icons/light/heavyrainandstorm.png', // Patchy freezing drizzle possible
  1087: 'assets/icons/light/thunderstorm.png', // Thundery outbreaks possible
  // Add more mappings as neededfbhjhjdff
};

Map<int, String> weatherIconsDark = {
  1000: 'assets/icons/dark/fullmoon.png', // Clear/Sunny
  1003: 'assets/icons/dark/clearnight.png', // Partly Cloudy
  1006: 'assets/icons/dark/nightcloudy.png', // Cloudy
  1009: 'assets/icons/dark/night.png', // Overcast
  1030: 'assets/icons/dark/night.png', // Mist
  1063: 'assets/icons/dark/nightrain.png', // Patchy rain possible
  1066: 'assets/icons/dark/nightrain.png', // Patchy snow possible
  1069: 'assets/icons/dark/nightrain.png', // Patchy sleet possible
  1072: 'assets/icons/dark/nightcloudy.png', // Patchy freezing drizzle possible
  1087: 'assets/icons/dark/nightcloudy.png', // Thundery outbreaks possible
  // Add more mappings as needed
};

String getWeatherIcon(int conditionCode, context) {
  return Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark ? weatherIconsDark[conditionCode] ?? 'assets/icons/dark/night.png' : weatherIconsLight[conditionCode] ?? 'assets/icons/light/sunny.png'; // Fallback icon
}

String getWeatherIconBasedTime(int conditionCode, BuildContext context, String time) {
  DateTime parsedTime = DateTime.parse(time);
  int hour = parsedTime.hour;
  bool isNight = hour >= 18 || hour < 6; // Night: 6:00 PM to 5:59 AM
  // bool isLight = hour >= 6 && hour < 18; // Day: 6:00 AM to 5:59 PM
 
  if (Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark) {
    return isNight
        ? weatherIconsDark[conditionCode] ?? 'assets/icons/dark/night.png'
        : weatherIconsLight[conditionCode] ?? 'assets/icons/light/sunny.png';
  } else {
    return isNight
        ? weatherIconsDark[conditionCode] ?? 'assets/icons/dark/night.png'
        : weatherIconsLight[conditionCode] ?? 'assets/icons/light/sunny.png';
  }
}