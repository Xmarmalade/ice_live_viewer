import 'package:flutter/material.dart';

class MyTheme {
  ThemeData lightThemeData = ThemeData(
      primarySwatch: Colors.indigo,
      useMaterial3: true,
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        headline2: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        headline3: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.blueGrey,
        ),
      ));

  ThemeData darkThemeData = ThemeData.from(
      colorScheme: const ColorScheme.dark(
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        headline2: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        headline3: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: Colors.indigo,
        ),
      ));
}
