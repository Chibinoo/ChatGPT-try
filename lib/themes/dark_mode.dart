import 'package:flutter/material.dart';

ThemeData darkMode=ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.blueGrey.shade900,
    primary: Colors.blueGrey.shade600,
    secondary: Colors.blueGrey.shade700,
    tertiary: Colors.blueGrey.shade800,
    inversePrimary: Colors.blueGrey.shade300,
    secondaryContainer: Colors.amber[700], // <--- Set your desired chip selected color
    error: Colors.red[400]!,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[800]!,
    selectedColor: Colors.amber[700]!,
    labelStyle: TextStyle(color: Colors.white),
  ),
);