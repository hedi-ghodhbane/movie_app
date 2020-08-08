import 'package:flutter/material.dart';

enum AppTheme { DarkTheme, LightTheme }

final Map<AppTheme, ThemeData> appTheme = {
  AppTheme.DarkTheme: ThemeData(
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.dark(),
      bottomAppBarColor: Colors.black,
      primaryColor: Colors.black,
      indicatorColor: Colors.purple,
      brightness: Brightness.dark,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
      ),
      textTheme: TextTheme(
          headline1: TextStyle(
              color: Colors.amber,
              fontSize: 20.0,
              fontWeight: FontWeight.bold))),
  AppTheme.LightTheme: ThemeData(
      colorScheme: ColorScheme.light(),
      bottomAppBarColor: Colors.black,
      indicatorColor: Colors.indigo,
      fontFamily: 'Poppins',
      primaryColor: Colors.teal,
      backgroundColor: Colors.blueGrey,
      brightness: Brightness.light,
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.black),
      textTheme: TextTheme(
          headline1: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w500))),
};
