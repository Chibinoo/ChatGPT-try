import 'package:flutter/material.dart';

ThemeData lightMode=ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.blueGrey.shade500,
    secondary: Colors.blueGrey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.blueGrey.shade900,
    secondaryContainer: Colors.teal[100], // <--- Set your desired chip selected color
    error: Colors.red,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[200]!,
    selectedColor: Colors.teal[100]!,
    labelStyle: TextStyle(color: Colors.black),
  )
);