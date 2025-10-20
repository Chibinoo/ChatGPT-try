import 'package:flutter/material.dart';

ThemeData darkMode=ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.blueGrey.shade900,
    primary: Colors.blueGrey.shade600,
    secondary: Colors.blueGrey.shade700,
    secondaryContainer: Colors.amber[700], // <--- Set your desired chip selected color
    error: Colors.red[400]!,
    tertiary: Colors.white
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[800]!,
    selectedColor: Colors.amber[700]!,
    labelStyle: TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData( // NavigationBar background
    backgroundColor: Colors.blueGrey.shade700,
  ),
);