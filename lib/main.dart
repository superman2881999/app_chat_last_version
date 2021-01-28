import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_chat_last_version/helper/authenticate.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/views/home.dart';
import 'package:flutter_app_chat_last_version/views/profile.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  static ThemeModel model = new ThemeModel();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      if (value != null) {
        setState(() {
          userIsLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeModel>(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (_, model, __) {
          MyApp.model = model;
          return MaterialApp(
              title: 'Chat With My Friends',
              builder: BotToastInit(),
              navigatorObservers: [BotToastNavigatorObserver()],
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: Colors.yellow,
                scaffoldBackgroundColor: const Color(0xFFFFF9C4),
                primarySwatch: Colors.yellow,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              darkTheme: ThemeData.dark(), // Provide dark theme.
              themeMode: MyApp.model.mode,
              home: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent, // transparent status bar
                  systemNavigationBarColor:
                      Colors.black, // navigation bar color
                  statusBarIconBrightness:
                      Brightness.dark, // status bar icons' color
                  systemNavigationBarIconBrightness:
                      Brightness.dark, //navigation bar icons' color
                ),
                child: userIsLoggedIn ? HomeScreen() : Authenticate(),
              ));
        },
      ),
    );
  }
}
