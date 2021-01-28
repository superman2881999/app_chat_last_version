import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/service/auth_service.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/chat_room_group_screen.dart';
import 'package:flutter_app_chat_last_version/views/chat_room_screen.dart';
import 'package:geolocator/geolocator.dart';

import 'drawer.dart';

class HomeScreen extends StatefulWidget {
  //Biến lưu vị trí hiện tại của người dùng
  static Position currentLocation;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthService authService = new AuthService();
  QuerySnapshot userInfoSnapshot;

  getUrlAvt()async{
    await HelperFunctions.getUserEmailSharedPreference().then((value) async {
      await DatabaseService().getUserData(value).then((value) async {
        userInfoSnapshot = value;
        Constants.urlAvt = await userInfoSnapshot.documents[0].data['urlAvt'];
      });
    });
  }

  static Future<void> getUserLocation() async {
    await Geolocator.getCurrentPosition().then((value) {
      HomeScreen.currentLocation = value;
    });
  }

  @override
  void initState() {
    setState(() {
      getUserLocation();
      getUrlAvt();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getUrlAvt();
    });
    final Draw drawer = new Draw(
      authService: authService,
      context: context,
    );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom:  TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person),text: "Nhắn tin riêng",),
              Tab(icon: Icon(Icons.group),text: "Nhắn tin nhóm"),
            ],
          ),
          title: Image.asset("images/title.png"),
        ),
        body: TabBarView (
          children: [
            ChatRoom(),
            ChatRoomGroup()
          ],
        ),
        drawer: drawer,

      ),
    );
  }
}
