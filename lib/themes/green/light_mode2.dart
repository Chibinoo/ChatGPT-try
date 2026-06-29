import 'package:flutter/material.dart';

ThemeData lightMode2 = ThemeData(
  colorScheme: ColorScheme.light(
    tertiary: Color.fromARGB(255, 45, 90, 67),
    secondaryContainer: Color.fromARGB(255, 152, 216, 170),
    secondary: Color.fromARGB(255, 26, 37, 33),
    primary: Color.fromARGB(255, 224, 234, 221),
  ),
  chipTheme: ChipThemeData(
    selectedColor: Colors.grey[800]!,
    backgroundColor: Color.fromARGB(255, 152, 216, 170),
    labelStyle: TextStyle(color: Color.fromARGB(255, 224, 234, 221)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    // NavigationBar background
    backgroundColor: Color.fromARGB(255, 224, 234, 221),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      iconColor: Color.fromARGB(255, 26, 37, 33),
      backgroundColor: Color.fromARGB(255, 224, 234, 221),
      shadowColor: Colors.blueGrey,
      elevation: 3,
    ),
  ),
  cardTheme: CardThemeData(shadowColor: Colors.blueGrey, elevation: 3),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return Color.fromARGB(255, 224, 234, 221);
    }
    return Color.fromARGB(255, 45, 90, 67);
  }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return Color.fromARGB(255, 224, 234, 221);
    }
    return Color.fromARGB(255, 224, 234, 221); // Use the default color.
  }),
  ),
);
