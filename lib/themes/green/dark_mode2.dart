import 'package:flutter/material.dart';

ThemeData darkMode2=ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(255, 45, 90, 67),
    secondaryContainer: Color.fromARGB(255, 152, 216, 170),
    secondary: Color.fromARGB(255, 26, 37, 33),
    tertiary: Color.fromARGB(255, 224, 234, 221)
  ),
    chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[800]!,
    selectedColor:  Color.fromARGB(255, 152, 216, 170),
    labelStyle: TextStyle(color: Color.fromARGB(255, 224, 234, 221)),
    secondaryLabelStyle: TextStyle(color: Color.fromARGB(255, 45, 90, 67))
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    // NavigationBar background
    backgroundColor: Color.fromARGB(255, 45, 90, 67),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 26, 37, 33),
      iconColor: Color.fromARGB(255, 224, 234, 221),
      shadowColor: Colors.blueGrey, 
      elevation: 3),
  ),
  cardTheme: CardThemeData(
    shadowColor: Colors.blueGrey,
    elevation: 3,
  )
);