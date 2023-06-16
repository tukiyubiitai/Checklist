import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light; //現在のテーマモード

  //現在のテーマがダークモードであるかをbool値で返す
  bool get isDarkMode => themeMode == ThemeMode.dark;

  //テーマモードの切り替え
  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    //変更を通知
    notifyListeners();
  }
}

class MyThemes {
  //ダークモード
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: ColorScheme.dark(),
    primaryColor: Colors.yellowAccent,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.yellowAccent),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.yellowAccent),
      ),
    ),
  );

  //通常時
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    ),
  );
}
