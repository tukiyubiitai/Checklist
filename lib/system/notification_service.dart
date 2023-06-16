import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class Noti {
  //flutterLocalNotificationsPlugin インスタンスの作成
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //初期化
  void initializePlatformSpecifics() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse res) {
      print("呼ばれました");
      debugPrint('payload:${res.payload}');
    });
  }

  //通知を表示する
  Future<void> showNotification(int minutes) async {
    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(
        true,
        true,
      ),
    );

    var iosChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      '設定完了！', // Notification Title
      '$minutes分後にアラームを設定しました',
      // Notification Body, set as null to remove the body
      platformChannelSpecifics,
      payload: 'Alarm Payload', //
    );
  }

  //指定された時間後に通知をスケジュールする
  Future<void> scheduleNotification(int minutes) async {
    var scheduleNotificationDateTime =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      channelDescription: "CHANNEL_DESCRIPTION 1",
      icon: 'app_icon',
      //sound: RawResourceAndroidNotificationSound('my_sound'),
      //largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      enableLights: true,
      color: Color.fromARGB(255, 255, 0, 0),
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      timeoutAfter: 10000,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifics = const DarwinNotificationDetails(
        // sound: 'my_sound.aiff',
        );

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '忘れ物はありませんか？',
      '外出前にもう一度リストを確認しましょう！',
      tz.TZDateTime.from(scheduleNotificationDateTime, tz.local),
      platformChannelSpecifics,
      payload: 'Test Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  //保留中の通知の数を取得するメソッドです。
  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print(p.length);
    return p.length;
  }

  //指定した通知IDの通知をキャンセルする
  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  //すべての通知をキャンセルする
  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
