import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/constant.dart';
import 'package:flutter_app_chat_last_version/helper/helper_functions.dart';
import 'package:flutter_app_chat_last_version/service/auth_service.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'home.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  @override
  State<StatefulWidget> createState() {
    return new SignInState();
  }
}

class SignInState extends State<SignIn> {
  final _formKey = new GlobalKey<FormState>();
  AuthService _auth = new AuthService();

  DatabaseService databaseService = new DatabaseService();

  TextEditingController emailUser = new TextEditingController();
  TextEditingController passWordUser = new TextEditingController();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  QuerySnapshot querySnapshot;
  String token;

  ProgressDialog pr;

  signIn(ProgressDialog progressDialog) async {
    if (_formKey.currentState.validate()) {
      pr.show();
     token = await firebaseMessaging.getToken();
      print(token);
      await _auth.signInWithEmailAndPassword(emailUser.text, passWordUser.text).then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(emailUser.text);

          await databaseService.updateToken(userId: userInfoSnapshot.documents[0].data['uid'],token:token);
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(emailUser.text);
          await HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.documents[0].data['fullName']
          );
          await HelperFunctions.saveTokenSharedPreference(token);

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });
          await progressDialog.hide();
         await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        }else{
          pr.hide();
          Constants.toastAddSuccess(context, "Chưa có tài khoản");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    return  Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "images/logo app.png",
                  fit: BoxFit.cover,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)
                                ? null
                                : "Vui lòng cung cấp một email hợp lệ";
                          },
                          controller: emailUser,
                          style: simpleTextFieldStyle(),
                          decoration: textfieldInputDecoration("Email")),
                      TextFormField(
                          obscureText: true,
                          validator: (value) {
                            return value.length > 6
                                ? null
                                : "Vui lòng cung cấp mật khẩu từ 6 ký tự trở lên";
                          },
                          controller: passWordUser,
                          style: simpleTextFieldStyle(),
                          decoration: textfieldInputDecoration("Mật khẩu")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Text("Quên mật khẩu ?",
                        style: greyColorText()),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    signIn(pr);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text("Đăng nhập", style: mediumTextFieldStyle()),
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
                      "Chưa có mật khẩu ? ",
                      style: minTextFieldStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Đăng ký",
                              style:greyColorText())),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
