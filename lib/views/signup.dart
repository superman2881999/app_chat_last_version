import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/service/auth_service.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/home.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  State<StatefulWidget> createState() {
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DatabaseService databaseService = new DatabaseService();


  TextEditingController userName = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController passWord = new TextEditingController();
  String urlAvt = "images/Avt_Default.jpg";

  Future<String> uploadFiles(File _image) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("avatar/${Path.basename(_image.path)}");
    StorageUploadTask uploadTask = ref.putFile(_image);
    await uploadTask.onComplete;
    var dowUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowUrl.toString();
    return url;
  }


  _onRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
      String token = await firebaseMessaging.getToken();
      print(token);
      await _auth.registerWithEmailAndPassword(userName.text, email.text, passWord.text,urlAvt,token).then((result) async {
        if (result != null) {
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email.text);
          await HelperFunctions.saveUserNameSharedPreference(userName.text);
          await HelperFunctions.saveTokenSharedPreference(token);

          print("Registered");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: _isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 100,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: GestureDetector(onTap: () async{
                            // ignore: deprecated_member_use
                            final file = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (file == null)
                              return CircularProgressIndicator();
                            else {
                                uploadFiles(file).then((value){
                                  if (value != null) {
                                    setState(() {
                                      urlAvt = value;
                                    });
                                  } else
                                    urlAvt = "images/Avt_Default.jpg";
                                });
                            }
                          },child: CircleAvatar(backgroundImage: urlAvt == "images/Avt_Default.jpg" ? AssetImage(urlAvt) : NetworkImage(urlAvt),maxRadius: MediaQuery.of(context).size.width/4)),
                        ),
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  validator: (value) {
                                    return value.isEmpty || value.length < 2
                                        ? "Vui lòng cung cấp tên người dùng"
                                        : null;
                                  },
                                  controller: userName,
                                  style: simpleTextFieldStyle(),
                                  decoration:
                                      textfieldInputDecoration("Tên người dùng")
                              ),
                              TextFormField(
                                  validator: (value) {
                                    return RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value)
                                        ? null
                                        : "Vui lòng cung cấp một email hợp lệ";
                                  },
                                  controller: email,
                                  style: simpleTextFieldStyle(),
                                  decoration:
                                      textfieldInputDecoration("Email")
                              ),
                              TextFormField(
                                  obscureText: true,
                                  validator: (value) {
                                    return value.length > 6
                                        ? null
                                        : "Vui lòng cung cấp mật khẩu 6 ký tự trở lên";
                                  },
                                  controller: passWord,
                                  style: simpleTextFieldStyle(),
                                  decoration:
                                      textfieldInputDecoration("Mật khẩu")
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: Text("Quên mật khẩu ?",
                              style: greyColorText()),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          _onRegister();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Text("Đăng ký", style: mediumTextFieldStyle()),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              gradient: gradient()),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                                width: 60,
                                height: 60,
                                child: Image.asset('images/facebook.png')),
                          ),
                          Expanded(
                            child: Container(
                                width: 60,
                                height: 60,
                                child: Image.asset('images/google.png')),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đã có tài khoản ? ",
                            style: minTextFieldStyle(),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.toggle();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text("Đăng nhập",
                                  style: greyColorText()),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height/10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
