import 'package:flutter/material.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier{
  //initaly light mode
  ThemeData _themeData=lightMode;
  //get current theme
  ThemeData get themeData=>_themeData;
  //check if its dark mode
  bool get isDarkMode=>_themeData==darkMode;
  //set theme
  set themeData(ThemeData themeData){
    _themeData=themeData;
    notifyListeners();
  }
  //toggel theme
  void toggelTheme(){
    if(_themeData==lightMode){
      themeData=darkMode;
    }else{
      themeData=lightMode;
    }
  }
}