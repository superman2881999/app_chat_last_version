import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constans.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/conversation_screen.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oktoast/oktoast.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchText = new TextEditingController();

  QuerySnapshot querySnapshot;

  initiateSearch() {
    databaseService.getUserByUserName(searchText.text).then((value) {
      setState(() {
        querySnapshot = value;
      });
    });
  }

  Widget searchList() {
    return querySnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: querySnapshot.documents.length,
            itemBuilder: (context, index) {
              return searchTile(
                userName: querySnapshot.documents[index].data["name"],
                userEmail: querySnapshot.documents[index].data["email"],
              );
            })
        : Container();
  }

  createChatRoomAndStartConversation({String userName}) {
    if (userName != Constants.myName) {
      String chatroomid = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomid": chatroomid,
      };
      DatabaseService().createChatRoom(chatroomid, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              chatRoomId: chatroomid,
            ),
          ));
    } else {
      print("you can't send message to yourself");
    }
  }

  Widget searchTile({String userName, String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(userName, style: mediumTextFieldStyle()),
                new Text(userEmail, style: mediumTextFieldStyle())
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomAndStartConversation(userName: userName);
            },
            child: Container(
              child: Text("Message", style: mediumTextFieldStyle()),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(children: [
          Container(
            decoration: BoxDecoration(gradient: gradient()),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchText,
                    style: TextStyle(color: Colors.white70),
                    decoration: InputDecoration(
                      hintText: "Search username...",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearch();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0x36FFFFFF),
                          const Color(0x0FFFFFFF)
                        ]),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      child: Center(child: Icon(Icons.search,color: Colors.white70,))),
                ),
              ],
            ),
          ),
          searchList(),
        ]),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
    return "$a\_$b";
}
