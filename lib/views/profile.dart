import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/main.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path/path.dart' as Path;

class ProfileUser extends StatefulWidget {
  static bool status = false;
  @override
  _ProfileUserState createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  ProgressDialog progressDialog;
  FirebaseUser user;
  QuerySnapshot singleInfoSnapshot;
  List<Map<String, List<String>>> listName = [];

  Future<String> uploadFiles(File _image, String folderName) async {
    progressDialog.show();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("$folderName/${Path.basename(_image.path)}");
    StorageUploadTask uploadTask = ref.putFile(_image);
    await uploadTask.onComplete;
    var dowUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowUrl.toString();
    return url;
  }
  getUser() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    setState(() {
      user = firebaseUser;
    });
  }

  getAllListSingle() async {
    listName.clear();
    await DatabaseService()
        .getAllSingle(user.uid + '_' + Constants.myName)
        .then((value) {
      singleInfoSnapshot = value;
      for (int i = 0; i < singleInfoSnapshot.documents.length; i++) {
        if (singleInfoSnapshot.documents[i].data["urlAvt"]
                .toString()
                .split("@")[0]
                .contains(Constants.myName) ||
            singleInfoSnapshot.documents[i].data["urlAvt"]
                .toString()
                .split("@")[1]
                .contains(Constants.myName)) {
          listName.add({
            singleInfoSnapshot.documents[i].data["singleId"]: singleInfoSnapshot
                .documents[i].data["urlAvt"]
                .toString()
                .split("@")
          });
        }
      }
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    //getUser();
    return Scaffold(
      appBar: AppBar(title: Text('Thông tin tài khoản')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                final file =
                    // ignore: deprecated_member_use
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                if (file == null)
                  return CircularProgressIndicator();
                else {
                  uploadFiles(file, "avatar").then((value) async {
                    if (value != null) {
                      setState(() {
                        Constants.urlAvt = value;
                        DatabaseService().updateAvtUser(
                            uid: user.uid, urlAvt: Constants.urlAvt);
                      });
                      getAllListSingle().then((value){
                        for (int i = 0; i < listName.length; i++) {
                          if (listName[i]
                              .values
                              .first[0]
                              .contains(Constants.myName)) {
                            print(listName[i].values.first[0].toString());
                            DatabaseService().updateUrlAvtSingle(
                                uid: listName[i].keys.first.toString(),
                                urlAvt:'${Constants.urlAvt}*'+
                                    '${Constants.myName}' + '@${listName[i].values.first[1]}');
                          }else{
                            DatabaseService().updateUrlAvtSingle(
                                uid: listName[i].keys.first.toString(),
                                urlAvt: '${listName[i].values.first[0]}' +
                                    '@${Constants.urlAvt}' +
                                    "*" +
                                    '${Constants.myName}');
                          }
                        }
                      });

                    } else {
                      Constants.urlAvt = "images/Avt_Default.jpg";
                    }
                    progressDialog.hide();
                    Constants.toastAddSuccess(
                        context, "Thay đổi ảnh đại diện thành công");
                  });
                }
              },
              child: CircleAvatar(
                backgroundImage: Constants.urlAvt == "images/Avt_Default.jpg"
                    ? AssetImage(Constants.urlAvt)
                    : NetworkImage(Constants.urlAvt),
                maxRadius: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tên người dùng: ", style: TextStyle(fontSize: 17)),
                  Text(Constants.myName, style: TextStyle(fontSize: 17))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Email: ", style: TextStyle(fontSize: 17)),
                  Text(Constants.email, style: TextStyle(fontSize: 17))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đổi chế độ: ", style: TextStyle(fontSize: 17)),
                  Switch(
                    activeColor: Colors.red,
                    value: ProfileUser.status,
                    onChanged: (value) {
                      setState(() {
                        ProfileUser.status = value;
                        if (ProfileUser.status) {
                          MyApp.model.toggleModeDark();
                        } else {
                          MyApp.model.toggleModeLight();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeModel with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  void toggleModeDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
  }

  void toggleModeLight() {
    _mode = ThemeMode.light;
    notifyListeners();
  }
}
