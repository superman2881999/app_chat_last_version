import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/service/auth_service.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/conversation_screen_group.dart';
import 'package:flutter_app_chat_last_version/views/search_group.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unicorndial/unicorndial.dart';

class ChatRoomGroup extends StatefulWidget {
  @override
  _ChatRoomGroupState createState() => _ChatRoomGroupState();
}

class _ChatRoomGroupState extends State<ChatRoomGroup> {
  FirebaseUser _user;
  AuthService authService = new AuthService();
  DatabaseService databaseService = new DatabaseService();
  Stream _groups;

  String _groupName;

  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Create"),
      onPressed: () async {
        if (_groupName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid).createGroup(val, _groupName);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Create a group"),
      content: TextField(
          onChanged: (val) {
            _groupName = val;
          },
          style: TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
      actions: [
        cancelButton,
        createButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget chatRoomGroupList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        var result = snapshot.data.documents;
        var size = MediaQuery.of(context).size;
        final double itemHeight = (size.height - kToolbarHeight) / 3;
        final double itemWidth = size.width / 2;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0),
          itemCount: result.length,
          itemBuilder: (context, index) {
            return ChatRoomTile(
              groupIcon: result[index].data["groupIcon"],
              nameGroup: result[index].data["groupName"],
              messageLast: result[index].data["recentMessage"],
            );
          },
        );
      },
    );
  }

  getUserInfo() async {
    _user = await FirebaseAuth.instance.currentUser();
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseService(uid: _user.uid)
        .getUserGroups(_user.uid + '_' + Constants.myName)
        .then((value) {
      setState(() {
        _groups = value;
      });
    });
  }

  @override
  void initState() {
    setState(() {
      getUserInfo();
      chatRoomGroupList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
        labelBackgroundColor: Colors.yellow,
        hasLabel: true,
        labelText: "Tìm nhóm",
        currentButton: FloatingActionButton(
          heroTag: "Tìm kiếm",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchGroupScreen()));
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelBackgroundColor: Colors.yellow,
        labelText: "Tạo nhóm mới",
        currentButton: FloatingActionButton(
            heroTag: "Nhóm",
            backgroundColor: Colors.redAccent,
            mini: true,
            onPressed: () {
              _popupDialog(context);
            },
            child: Icon(
              Icons.group,
              color: Colors.white,
            ))));
    return Scaffold(
      body: chatRoomGroupList(),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.yellow,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.menu),
          childButtons: childButtons),
    );
  }
}

class ChatRoomTile extends StatefulWidget {
  const ChatRoomTile({this.groupIcon, this.nameGroup, this.messageLast});
  final String nameGroup;
  final String messageLast;
  final String groupIcon;

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  DatabaseService databaseService = new DatabaseService();
  QuerySnapshot groupInfoSnapshot;

  getGroup() async {
    groupInfoSnapshot =
        await DatabaseService().getGroupByNameGroup(widget.nameGroup);
  }

  @override
  void initState() {
    setState(() {
      getGroup();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getGroup();
    return Container(
      margin: EdgeInsets.only(right: 5.0, left: 5.0, top: 10.0),
      child: Card(
        elevation: 10.0,
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: gradient2(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  widget.nameGroup,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Column(
                  children: [
                    Container(
                        width: 60.0,
                        height: 60.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: CircleAvatar(
                          maxRadius: 50,
                          backgroundImage:
                              widget.groupIcon == "images/Avt_Default.jpg"
                                  ? AssetImage(widget.groupIcon)
                                  : NetworkImage(widget.groupIcon),
                        )),
                    SizedBox(height: 10.0),
                    Text(widget.messageLast,
                        style: mediumTextFieldStyle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ConversationScreenGroup(
                                        nameRoomChat: widget.nameGroup,
                                        id: groupInfoSnapshot
                                            .documents[0].data['groupId'],
                                      ),
                                    ));
                              });
                            },
                            child: container(Icons.send)),
                        container(Icons.video_call),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
