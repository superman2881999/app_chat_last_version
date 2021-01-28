import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/models/user_model.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';


class AddMembers extends StatefulWidget {
  AddMembers({this.groupName, this.groupId});
  final groupId;
  final groupName;
  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  QuerySnapshot querySnapshot;
  List<User> listUser = [];
  List<Map<User, bool>> listIsCheck = [];
  List<User> listUserSelected = [];

  getData() async {
    await DatabaseService().getUsers().then((value) async {
      querySnapshot = value;
      listIsCheck.clear();
      listUser.clear();
      setState(() {
        for (int i = 0; i < querySnapshot.documents.length; i++) {
          listUser.add(User(
              uid: querySnapshot.documents[i].data["uid"],
              email: querySnapshot.documents[i].data["email"],
              fullName: querySnapshot.documents[i].data["fullName"]));
          listIsCheck.add({listUser[i]: false});
        }
      });
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Thêm người',
           ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              setState(() {
                for (int i = 0; i < listUserSelected.length; i++) {
                  DatabaseService().addMember(
                      widget.groupId, widget.groupName, listUserSelected[i]);
                  listUser.remove(listUserSelected[i]);
                  listIsCheck.remove(listIsCheck[i]);
                }
                listUserSelected.clear();
              });
              Constants.toastAddSuccess(context,"Thêm thành công");
               Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: listUser.length,
        itemBuilder: (context, index) {
          return listUser.isEmpty
              ? const Center(child: Text("Không có người nào"))
              : ListTile(
                  leading: Icon(Icons.person),
                  title: Text(listUser[index].fullName),
                  subtitle: Text(listUser[index].email),
                  trailing: listIsCheck[index][listUser[index]] == true
                      ? IconButton(
                          icon: Icon(Icons.radio_button_checked),
                          onPressed: () {
                            setState(() {
                              listIsCheck[index][listUser[index]] =
                                  !listIsCheck[index][listUser[index]];
                              listUserSelected.remove(listUser[index]);
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.radio_button_unchecked),
                          onPressed: () {
                            setState(() {
                              listIsCheck[index][listUser[index]] =
                                  !listIsCheck[index][listUser[index]];
                              listUserSelected.add(listUser[index]);
                            });
                          },
                        ));
        },
      ),
    );
  }
}


