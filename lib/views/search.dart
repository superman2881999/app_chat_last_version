import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/conversation_screen.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseUser _user;
  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchText = new TextEditingController();

  QuerySnapshot querySnapshot;
  QuerySnapshot singleInfoSnapshot;
  QuerySnapshot userInfoSnapshot, userInfoSnapshot2;

  ProgressDialog pr;

  initiateSearch() {
    databaseService.searchUserByName(searchText.text).then((value) {
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
                userNameOther: querySnapshot.documents[index].data["fullName"],
                emailOther: querySnapshot.documents[index].data["email"],
              );
            })
        : Container();
  }

  createChatRoomAndStartConversation(
      {String userNameOther,
      String emailOther,
      ProgressDialog progressDialog}) async {
    _user = await FirebaseAuth.instance.currentUser();
    if (userNameOther != Constants.myName) {
      userInfoSnapshot = await DatabaseService().getUserData(emailOther);
      userInfoSnapshot2 = await DatabaseService().getUserData(Constants.email);
      await DatabaseService(uid: _user.uid).createChatSingle(
          userNameOther,
          await userInfoSnapshot.documents[0].data['uid'],
          await userInfoSnapshot2.documents[0].data['urlAvt'],
          await userInfoSnapshot.documents[0].data['urlAvt']);

      await DatabaseService()
          .getSingleByNameSingle(userNameOther + "_" + Constants.myName)
          .then((value) async {
        singleInfoSnapshot = await value;
        if (singleInfoSnapshot.documents.length == 0) {
          DatabaseService()
              .getSingleByNameSingle(Constants.myName + "_" + userNameOther)
              .then((value) async {
            singleInfoSnapshot = await value;
            await progressDialog.hide();
            await Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return ConversationScreen(
                  nameRoomChat: userNameOther,
                  id: singleInfoSnapshot.documents[0].data['singleId'],
                );
              },
            ));
          });
        } else {
          await Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return ConversationScreen(
                nameRoomChat: userNameOther,
                id: singleInfoSnapshot.documents[0].data['singleId'],
              );
            },
          ));
        }
      });
    } else {
      Constants.toastAddSuccess(context, "Bạn không thể tự nhắn tin với mình");
    }
  }

  Widget searchTile({String userNameOther, String emailOther}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Color(0xFFFFFF8D)),
      child: Row(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userNameOther,
                    style: TextStyle(color: Colors.black, fontSize: 16.0)),
                Text(emailOther,
                    style: TextStyle(color: Colors.black, fontSize: 16.0))
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              pr.show();
              createChatRoomAndStartConversation(
                  userNameOther: userNameOther,
                  emailOther: emailOther,
                  progressDialog: pr);
            },
            child: Container(
              child: Text("Nhắn tin",
                  style: TextStyle(color: Colors.white, fontSize: 17.0)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  gradient: gradient2(),
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);

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
                      hintText: "Tìm tên người dùng...",
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
                        gradient: gradient2(),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      child: Center(
                          child: Icon(
                        Icons.search,
                        color: Colors.white70,
                      ))),
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
