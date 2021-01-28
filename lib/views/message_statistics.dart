import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/chart_length_group.dart';
import 'package:flutter_app_chat_last_version/views/chart_length_single.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MessageStatistics extends StatefulWidget {
  const MessageStatistics({this.uidUser});
  final String uidUser;
  @override
  State<StatefulWidget> createState() {
    return new _MessageStatisticsState();
  }
}

class _MessageStatisticsState extends State<MessageStatistics>
    with TickerProviderStateMixin {
  DatabaseService databaseService = new DatabaseService();
  Stream chatRoomsStream, chatRoomsGroupStream;
  List<Widget> widgetOptions = [];
  AnimationController _resizableController;
  QuerySnapshot amountGroupSnapshot, amountSingleSnapshot;
  int amountGroup, amountSingle;

  int _selectedIndex = 0;

  getSingleInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    await databaseService
        .getChatRooms(widget.uidUser + '_' + Constants.myName)
        .then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
  }

  getGroupInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    await databaseService
        .getChatRoomsGroup(widget.uidUser + '_' + Constants.myName)
        .then((value) {
      setState(() {
        chatRoomsGroupStream = value;
      });
    });
  }

  getAmountGroup() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    await databaseService
        .getAmountGroup(widget.uidUser + '_' + Constants.myName)
        .then((value) {
      setState(() {
        amountGroupSnapshot = value;
        amountGroup = amountGroupSnapshot.documents.length;
        print(amountGroup);
      });
    });
  }

  getAmountSingle() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    await databaseService
        .getAmountSingle(widget.uidUser + '_' + Constants.myName)
        .then((value) {
      setState(() {
        amountSingleSnapshot = value;
        amountSingle = amountSingleSnapshot.documents.length;
        print(amountSingle);
      });
    });
  }

  @override
  void initState() {
    setState(() {
      getSingleInfo();
      getGroupInfo();
      getAmountGroup();
      getAmountSingle();
    });
    _resizableController = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _resizableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      widgetOptions = [
        ChartLengthSingle(
            amountSingle: amountSingle,
            chatRoomsStream: chatRoomsStream,
            databaseService: databaseService,
            resizableController: _resizableController),
        ChartLengthGroup(
            amount: amountGroup,
            chatRoomsGroupStream: chatRoomsGroupStream,
            databaseService: databaseService,
            resizableController: _resizableController),
      ];
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Thống kê tin nhắn"),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.redAccent),
        child: GNav(
            gap: 7,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            duration: const Duration(milliseconds: 800),
            tabBackgroundColor: Colors.red,
            tabs: [
              GButton(
                icon: Icons.person,
                text: 'Nhắn tin riêng',
              ),
              GButton(
                icon: Icons.group,
                text: 'Nhắn tin nhóm',
              )
            ],
            selectedIndex: _selectedIndex,
            //Hàm cập nhật vị trí hiện tại của màn hình
            onTabChange: (index) {
              if (mounted) {
                setState(() {
                  _selectedIndex = index;
                });
              }
            }),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 10, right: 10),
        height: MediaQuery.of(context).size.height,
        child: widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
