import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/db/database.dart';

import '../model/theme_provider.dart';
import 'home_page.dart';
import '../main.dart';

class TodoInputScreen extends StatefulWidget {
  @override
  State<TodoInputScreen> createState() => _TodoInputScreenState();
}

class _TodoInputScreenState extends State<TodoInputScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final int maxCharacterCount = 10;
  final formKey = GlobalKey<FormState>();

  //スナックバー
  void _showSnackBar({
    required String text,
    required Color darkModeBackgroundColor,
    required Color lightModeBackgroundColor,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.isDarkMode
        ? darkModeBackgroundColor
        : lightModeBackgroundColor;

    final snackBar = SnackBar(
      content: Text(
        text,
        style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.black : Colors.white),
      ),
      backgroundColor: backgroundColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //登録する
  _submitTask() async {
    if (textEditingController.text == "") {
      _showSnackBar(
        text: '何も入力されていません',
        darkModeBackgroundColor: Colors.red,
        lightModeBackgroundColor: Colors.red,
      );
      return;
    }
    var task = Task(
      name: textEditingController.text,
      isMemorized: false,
    );
    try {
      await database.insertTask(task);
      print(task);
      textEditingController.clear();
      _showSnackBar(
        text: '登録完了しました',
        darkModeBackgroundColor: Colors.yellow,
        lightModeBackgroundColor: Colors.deepPurpleAccent,
      );
    } on SqliteException catch (e) {
      print("呼ばれました");
      _showSnackBar(
          text: '既に登録済みです$e',
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("新しく追加する"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyHomePage()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: formKey,
              child: TextFormField(
                  autofocus: true,
                  controller: textEditingController,
                  maxLength: maxCharacterCount,
                  style: TextStyle(fontSize: 40),
                  decoration: InputDecoration(
                      hintText: "忘れ物を追加", hintStyle: TextStyle(fontSize: 20))),
            ),
            SizedBox(height: 26.0),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    side: BorderSide(
                      color: themeProvider.isDarkMode
                          ? Colors.yellow
                          : Colors.blue, // 外枠の色を設定
                      width: 1.0, // 外枠の幅を設定
                    ),
                    borderRadius: BorderRadius.circular(50.0), // 角丸の半径を指定
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  themeProvider.isDarkMode
                      ? Colors.black
                      : Colors.deepPurpleAccent, // 背景色を設定
                ),
              ),
              onPressed: _submitTask,
              child: Text(
                '登録する',
                style: TextStyle(
                  fontSize: 30,
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
