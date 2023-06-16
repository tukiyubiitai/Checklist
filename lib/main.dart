import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:todo/model/theme_provider.dart';

import 'db/database.dart';
import 'screen/home_page.dart';

late MyDatabase database;

void main() {
  database = MyDatabase();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));
  runApp(
      ChangeNotifierProvider(create: (_) => ThemeProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // デバッグバナーを非表示にする
      title: 'Flutter Demo',
      theme: MyThemes.lightTheme,
      themeMode: themeProvider.themeMode,
      darkTheme: MyThemes.darkTheme,
      home: MyHomePage(),
    );
  }
}
