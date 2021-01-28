import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/conversation_screen_group.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';

class SearchGroupScreen extends StatefulWidget {
  @override
  _SearchGroupScreenState createState() => _SearchGroupScreenState();
}

class _SearchGroupScreenState extends State<SearchGroupScreen> {

  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchText = new TextEditingController();

  QuerySnapshot querySnapshot;

  initiateSearch() {
    databaseService.searchGroupByNameGroup(searchText.text).then((value) {
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
            nameGroup: querySnapshot.documents[index].data["groupName"],
            admin: querySnapshot.documents[index].data["admin"],
          );
        })
        : Container();
  }

  startConversation({String groupName, String admin}) async {

      QuerySnapshot singleInfoSnapshot = await DatabaseService().getGroupByNameGroup(groupName);
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreenGroup(
              nameRoomChat: groupName,id: singleInfoSnapshot.documents[0].data['groupId'],
            ),
          ));

  }

  Widget searchTile({String nameGroup, String admin}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Color(0xFFFFFF8D)),
      child: Row(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nameGroup,
                    style: TextStyle(color: Colors.black, fontSize: 16.0)),
                Text("Người tạo: " + admin,
                    style: TextStyle(color: Colors.black, fontSize: 16.0))
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              startConversation(
                  groupName: nameGroup, admin: admin);
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
                      hintText: "Tìm tên nhóm ...",
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
