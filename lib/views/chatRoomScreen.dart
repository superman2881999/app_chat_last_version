import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/authenticate.dart';
import 'package:flutter_app_chat_last_version/helper/constans.dart';
import 'package:flutter_app_chat_last_version/helper/helperFunctions.dart';
import 'package:flutter_app_chat_last_version/service/authService.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/conversation_screen.dart';
import 'package:flutter_app_chat_last_version/views/search.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'drawer.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthService authService = new AuthService();
  DatabaseService databaseService = new DatabaseService();
  Stream chatRoomsStream;

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  List<String> username = snapshot
                      .data.documents[index].data["chatroomid"]
                      .toString()
                      .split("_");
                  return ChatRoomTile(
                    userName: username[0],
                    chatRoomId:
                        snapshot.data.documents[index].data["chatroomid"],
                  );
                },
              )
            : Container(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getuserNameSharePreference();
    databaseService.getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Draw drawer = new Draw(
      authService: authService,
      context: context,
    );
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("images/title.png"),
      ),
      body: ChatRoomList(),
      drawer: drawer,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ));
        },
      ),
    );
  }
}

class ChatRoomTile extends StatefulWidget {
  final String userName;
  final String chatRoomId;
  ChatRoomTile({this.userName, this.chatRoomId});

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  Stream getMessageLast;
  DatabaseService databaseService = new DatabaseService();
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      getMessageLast =
          databaseService.getMessageLastOfChat(chatRoomId: widget.chatRoomId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    bool isClicked = false;
    return Container(
      margin: EdgeInsets.only(right: 5.0, left: 5.0, top: 10.0),
      child: Card(
        elevation: 10.0,
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              gradient: LinearGradient(colors: [Colors.purple, Colors.purple])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                width: 40.0,
                height: 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue),
                child: Text(
                  "${widget.userName.substring(0, 1).toUpperCase()}",
                  style: mediumTextFieldStyle(),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      child: StreamBuilder(
                        stream: getMessageLast,
                        builder: (context, snapshot) {
                          if (snapshot.data == null)
                            return CircularProgressIndicator();
                          final docs = snapshot.data.documents;
                          bool isCheckSend =
                              docs[0]['sendBy'] != Constants.myName;
                          String isCheck =
                              "/data/user/0/com.example.flutter_app_chat_last_version/cache/";
                          return docs.length != 0
                              ? Text(
                                  isCheckSend
                                      ? (docs[0]['message']
                                              .toString()
                                              .contains(isCheck)
                                          ? "You received a image"
                                          : docs[0]['message'])
                                      : (docs[0]['message']
                                              .toString()
                                              .contains(isCheck)
                                          ? "You sent a image"
                                          : "You" + ": " + docs[0]['message']),
                                  style: mediumTextFieldStyle(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1)
                              : Container();
                        },
                      ),
                    )
                  ],
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          isClicked = !isClicked;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationScreen(
                                    chatRoomId: widget.chatRoomId),
                              ));
                        });
                      },
                      child: container(Icons.message, isClicked)),
                  container(Icons.video_call, isClicked),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
