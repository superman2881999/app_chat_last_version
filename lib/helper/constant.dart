import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Constants {
  static String key = "AIzaSyD_mv8sqRVeTIR49wpoiM5UPaUqkS9mzNY";
  static String myName = "";
  static String email = "";
  static String urlAvt = "images/Avt_Default.jpg";
  static Future<void> toastAddSuccess(
      BuildContext context, String input) async {
    return BotToast.showText(
        text: input,
        duration: const Duration(seconds: 2),
        backButtonBehavior: BackButtonBehavior.none,
        align: const Alignment(0, 0.8),
        animationDuration: const Duration(milliseconds: 200),
        animationReverseDuration: const Duration(milliseconds: 200),
        textStyle:
        TextStyle(color: const Color(0xFFFFFFFF), fontSize: 17.toDouble()),
        borderRadius: BorderRadius.circular(8.toDouble()),
        backgroundColor: const Color(0x00000000),
        contentColor: const Color(0x8A000000));
  }
  static FlutterLocalNotificationsPlugin initNotify() {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = IOSInitializationSettings();
    const initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    return flutterLocalNotificationsPlugin;
  }

  static Future showNotificationWithDefaultSound(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String nameNotification,
      String description) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      nameNotification,
      description,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }



}
