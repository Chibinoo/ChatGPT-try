import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.blueGrey.shade500,
    secondary: Colors.blueGrey.shade200,
    secondaryContainer: Colors.teal, // ChoiceChip selected color
    error: Colors.red,
    tertiary: Colors.black
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[200]!, // ChoiceChip background
    selectedColor: Colors.teal[100]!,   // ChoiceChip selected
    labelStyle: TextStyle(color: Colors.black),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData( // NavigationBar background
    backgroundColor: Colors.blueGrey.shade100,
  ),
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,
);