import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/classig/dark_mode.dart';
import 'package:flutter_application_1/themes/classig/light_mode.dart';
import 'package:flutter_application_1/themes/green/dark_mode2.dart';
import 'package:flutter_application_1/themes/green/light_mode2.dart';

import 'package:hive/hive.dart';

//one value per preset
enum AppThemePreset{
  green,
  classic;

  //string to dropdown 
  String get label =>switch(this){
    AppThemePreset.green=>'Green',
    AppThemePreset.classic=>'Classic',
  };

  //reconstructt from string stored in hive
  static AppThemePreset fromString(String value)=>
    AppThemePreset.values.firstWhere(
      (e)=>e.name==value,
      orElse: () => AppThemePreset.green,
    );
}

class ThemeProvider extends ChangeNotifier{
  AppThemePreset _preset = AppThemePreset.green;
  bool _darkMode= false;

//---------------GETTERS----------------------
  AppThemePreset get preset=>_preset;
  bool get isDarkMode=>_darkMode;

  ThemeData get themeData=>switch(_preset){
    AppThemePreset.green=>_darkMode?darkMode2:lightMode2,
    AppThemePreset.classic=>_darkMode?darkMode:lightMode,
  };

//Load saved values from hive
void loadFromHive(){
  final box=Hive.box('settings');
  _preset=AppThemePreset.fromString(box.get('themePreset', defaultValue: 'green')as String,);
  _darkMode=box.get('themeDarkMode',defaultValue: false)as bool;
  notifyListeners();
}
//on value change Preset to Hive
void _save(){
  final box=Hive.box('settings');
  box.put('themePresset', _preset.name);
  box.put('themeDarkMode', _darkMode);
}

//Puublic action
void toggelTheme(){
  _darkMode=!_darkMode;
  _save();
  notifyListeners();
}
void setPreset(AppThemePreset preset){
  _preset=preset;
  _save();
  notifyListeners();
}
}