import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:todo/db/database.dart';
import 'package:todo/screen/setting_screen.dart';
import 'package:todo/screen/todo_input_screen.dart';
import 'package:flutter/cupertino.dart';

import '../model/alarm_model.dart';
import '../model/theme_provider.dart';
import '../main.dart';
import '../system/notification_service.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> _tasksList = []; // 初期化の追加
  bool isOpened = false;

  // int selectedMinutes = 0;
  final AlarmModel alarmModel = AlarmModel();

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<SideMenuState> _endSideMenuKey = GlobalKey<SideMenuState>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // 追加

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _requestIOSPermission();
      Noti().initializePlatformSpecifics();
    }
    _getAllTask();
  }

  void _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: false,
          badge: true,
          sound: false,
        );
  }

  // databaseから全て取得
  void _getAllTask() async {
    _tasksList = await database.allTasks;
    setState(() {});
  }

  //全て削除
  _allDeleteItem() async {
    await database.deleteAllTasks();
  }

  //リスト追加
  _insertItem(Task task) async {
    await database.insertTask(task);
  }

  // 削除
  void _deleteTask(Task task) async {
    await database.deleteTask(task);
    _showSnackBar(
        text: '削除しました',
        darkModeBackgroundColor: Colors.yellowAccent,
        lightModeBackgroundColor: Colors.deepPurpleAccent);
    _getAllTask(); // タスクリストを更新する
  }

  //チェック
  void _updateTaskIsMemorized(Task task) async {
    final newIsMemorizedValue = !task.isMemorized;
    final updatedTask = task.copyWith(isMemorized: newIsMemorizedValue);
    await database.updateTask(updatedTask);
    _getAllTask();
  }

  // スナックバー
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

  // サイドメニューのトグルを切り替えるメソッド
  toggleMenu([bool end = false]) {
    // サイドメニューのキーを取得する
    final _state =
        end ? _endSideMenuKey.currentState! : _sideMenuKey.currentState!;

    if (_state.isOpened) {
      // サイドメニューが開いている場合、閉じる。
      _state.closeSideMenu();
    } else {
      //閉じている場合、開く。
      _state.openSideMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return SideMenu(
      key: _endSideMenuKey,
      inverse: true,
      // end side menu
      background:
          themeProvider.isDarkMode ? Colors.black45 : Colors.deepPurpleAccent,
      type: SideMenuType.slideNRotate,
      menu: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: _SideMenuItems(),
      ),
      onChange: (_isOpened) {
        setState(() {
          isOpened = _isOpened;
        });
      },
      child: IgnorePointer(
        ignoring: isOpened,
        child: Scaffold(
          appBar: AppBar(
            title: Text("忘れ物リスト"),
            actions: [
              IconButton(
                onPressed: () => toggleMenu(true),
                icon: Icon(Icons.menu),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            elevation: 4.0,
            icon: Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
            label: Text(
              '追加する',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            backgroundColor: themeProvider.isDarkMode
                ? Colors.black
                : Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.yellowAccent
                    : Colors.blue, // 外枠の色を設定
                width: 2.0, // 外枠の幅を設定
              ),
              borderRadius: BorderRadius.circular(50.0), // カスタム形状の角丸を設定
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoInputScreen(),
                ),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.sunny
                            : Icons.nightlight,
                        size: 35,
                        color: themeProvider.isDarkMode
                            ? Colors.yellowAccent
                            : Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          final provider = Provider.of<ThemeProvider>(context,
                              listen: false);
                          provider.toggleTheme(
                              !themeProvider.isDarkMode); // ダークモードの切り替え
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.alarm_on_outlined,
                        color: alarmModel.isAlarmSet ? Colors.yellow : null,
                        // 条件によって色を変更
                        size: 40,
                      ),
                      onPressed: () async {
                        int pendingCount =
                            await Noti().getPendingNotificationCount();
                        setState(() {
                          alarmModel.isAlarmSet =
                              pendingCount > 0 ? true : false;
                          print(alarmModel.isAlarmSet);
                        });
                        dialog();
                      },
                    ),
                  )
                ]),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ChangeNotifierProvider.value(
              value: themeProvider,
              child: ListView.builder(
                  itemCount: _tasksList.length,
                  itemBuilder: (context, index) {
                    final task = _tasksList[index];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteTask(task),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 500, // カードの幅を指定
                          height: 200, // カードの高さを指定
                          child: Card(
                            elevation: 5.0,
                            // color: task.isMemorized
                            //     ? Colors.yellow.shade50
                            //     : null,
                            // isCheckedがtrueの場合に緑色に設定
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Center(
                              child: ListTile(
                                title: SingleChildScrollView(
                                  child: Text(
                                    task.name,
                                    style: TextStyle(
                                      decoration: task.isMemorized
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontSize: 50,
                                    ),
                                  ),
                                ),
                                subtitle: task.isMemorized
                                    ? Text(
                                        DateFormat('M月d日 HH時 mm分')
                                            .format(DateTime.now()),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                                trailing: GestureDetector(
                                  onTap: () {
                                    _updateTaskIsMemorized(task);
                                  },
                                  child: task.isMemorized
                                      ? Icon(
                                          Icons.check_box,
                                          color: themeProvider.isDarkMode
                                              ? Colors.yellow
                                              : Colors.deepPurpleAccent,
                                          size: 80,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          size: 80,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _SideMenuItems() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
          ),
          ListTile(
            onTap: () {
              toggleMenu(true);
            },
            leading: const Icon(Icons.home, size: 35.0, color: Colors.white),
            title: const Text("Home"),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              _sortUpItems();
              toggleMenu(true);
            },
            leading: Icon(Icons.arrow_upward, size: 35.0, color: Colors.white),
            title: const Text("チェック済みを上に"),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              _sortDownItems();
              toggleMenu(true);
            },
            leading: const Icon(Icons.arrow_downward,
                size: 35.0, color: Colors.white),
            title: const Text("チェック済みを下に"),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              _uncheckAllTasks();
              toggleMenu(true);
            },
            leading: const Icon(Icons.check_box_outline_blank,
                size: 35.0, color: Colors.white),
            title: const Text("チェックを全てクリアする"),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text("全てのリストを削除してもよろしいでしょうか？"),
                      actions: [
                        TextButton(
                          child: Text("はい"),
                          onPressed: () {
                            _allDeleteItem();
                            _getAllTask();
                            Navigator.of(context).pop(true);
                            toggleMenu(true);
                            _showSnackBar(
                                text: "リストを全て削除しました",
                                darkModeBackgroundColor: Colors.yellowAccent,
                                lightModeBackgroundColor:
                                    Colors.deepPurpleAccent);
                          },
                        ),
                        TextButton(
                          child: Text("いいえ"),
                          onPressed: () {
                            //そのまま画面が閉じる
                            Navigator.of(context).pop(false);
                          },
                        )
                      ],
                    );
                  });
            },
            leading: const Icon(Icons.delete, size: 35.0, color: Colors.white),
            title: const Text("リスト全て削除"),
            textColor: Colors.white,
            dense: true,
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            leading:
                const Icon(Icons.settings, size: 35.0, color: Colors.white),
            title: const Text("設定"),
            textColor: Colors.white,
            dense: true,
          ),
        ],
      ),
    );
  }

  //全てチェックを外す
  _uncheckAllTasks() async {
    if (_tasksList.isEmpty) {
      _showSnackBar(
        text: "並び替えるリストがありません",
        darkModeBackgroundColor: Colors.red,
        lightModeBackgroundColor: Colors.red,
      );
    } else if (_tasksList.every((item) => item.isMemorized == false)) {
      // チェックされているリストがない場合の処理を追加
      _showSnackBar(
        text: "並び替えるリストがありません",
        darkModeBackgroundColor: Colors.red,
        lightModeBackgroundColor: Colors.red,
      );
    }
    ;
    await database.uncheckAllTasks();
    _getAllTask();
    _showSnackBar(
      text: "チェックを外しました",
      darkModeBackgroundColor: Colors.yellowAccent,
      lightModeBackgroundColor: Colors.deepPurpleAccent,
    );
  }

  //下に並び替え
  _sortDownItems() async {
    _tasksList = await database.allWordsSortedDescending;
    if (_tasksList.isEmpty) {
      _showSnackBar(
          text: "並び替えるリストがありません",
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
      return;
    } else if (_tasksList.every((item) => item.isMemorized == false)) {
      _showSnackBar(
          text: "チェックされているリストがありません",
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
      return;
    } else if (_tasksList.length == 1) {
      _showSnackBar(
          text: "並び替えるにはリストが１つ以上必要です",
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
      return;
    } else {
      for (int i = 0; i < _tasksList.length; i++) {
        print("1回目${_tasksList}");
        await database.deleteTask(_tasksList[i]);
        await _insertItem(_tasksList[i]);
      }
      _showSnackBar(
        text: "並び替えに完了しまいした",
        darkModeBackgroundColor: Colors.yellowAccent,
        lightModeBackgroundColor: Colors.deepPurpleAccent,
      );
    }
    _getAllTask();
    setState(() {});
  }

  //上に並び替え
  _sortUpItems() async {
    _tasksList = await database.allWordsSortedAscending;
    if (_tasksList.isEmpty) {
      _showSnackBar(
          text: "並び替えるリストがありません",
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
      return;
    } else if (_tasksList.every((item) => item.isMemorized == false)) {
      _showSnackBar(
          text: "チェックされているリストがありません",
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
      return;
    } else if (_tasksList.length == 1) {
      _showSnackBar(
          text: "並び替えるにはリストが１つ以上必要です",
          darkModeBackgroundColor: Colors.red,
          lightModeBackgroundColor: Colors.red);
      return;
    } else {
      for (int i = 0; i < _tasksList.length; i++) {
        print("1回目${_tasksList}");
        await database.deleteTask(_tasksList[i]);
        await _insertItem(_tasksList[i]);
      }
      _showSnackBar(
        text: "並び替えに完了しまいした",
        darkModeBackgroundColor: Colors.yellowAccent,
        lightModeBackgroundColor: Colors.deepPurpleAccent,
      );
    }
    _getAllTask();
    setState(() {});
  }

  void dialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(alarmModel.isAlarmSet ? 'アラームを解除' : 'アラームを設定'),
          content: alarmModel.isAlarmSet
              ? Text(
                  '${alarmModel.savedMinutes}分後にアラームを設定されています。\nアラームを解除しますか？')
              : StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('何分後にアラームを設定しますか？'),
                        SizedBox(height: 20),
                        CupertinoPicker(
                          itemExtent: 32,
                          onSelectedItemChanged: (int value) {
                            alarmModel.savedMinutes = (value + 1) * 5;
                            Noti().scheduleNotification(
                                alarmModel.savedMinutes.toInt());
                            setState(() {});
                          },
                          children: _buildPickerItems(),
                        ),
                      ],
                    );
                  },
                ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(alarmModel.isAlarmSet ? '解除' : '設定'),
              onPressed: () {
                if (alarmModel.isAlarmSet) {
                  alarmModel.isAlarmSet = false;
                  Noti().cancelAllNotification();
                  _showSnackBar(
                      text: 'アラームを解除しました',
                      darkModeBackgroundColor: Colors.yellowAccent,
                      lightModeBackgroundColor: Colors.deepPurpleAccent);
                } else {
                  if (alarmModel.savedMinutes == 0) {
                    alarmModel.savedMinutes += 1; // 0の場合に+5をする
                  }
                  alarmModel.isAlarmSet = true;
                  Noti().scheduleNotification(alarmModel.savedMinutes.toInt());
                  _showSnackBar(
                      text: '${alarmModel.savedMinutes}分後にアラームを設定しました',
                      darkModeBackgroundColor: Colors.yellowAccent,
                      lightModeBackgroundColor: Colors.deepPurpleAccent);
                }
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static List<Widget> _buildPickerItems() {
    List<Widget> items = [];

    // 分単位で表示する時間の範囲を指定
    int maxMinutes = 120;

    // 分単位で表示する時間を追加
    for (int i = 5; i <= maxMinutes; i += 5) {
      items.add(Text('$i 分後'));
    }

    return items;
  }
}
