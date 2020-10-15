import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/helperFunctions.dart';
import 'package:flutter_app_chat_last_version/service/authService.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/views/chatRoomScreen.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SignInState();
  }
}

class SignInState extends State<SignIn> {
  final formKey = new GlobalKey<FormState>();
  AuthService authService = new AuthService();
  DatabaseService databaseService = new DatabaseService();
  TextEditingController emailUser = new TextEditingController();
  TextEditingController passWordUser = new TextEditingController();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  QuerySnapshot querySnapshot;

  bool isLoading = false;
  signIn() {
    if (formKey.currentState.validate()) {
      HelperFunctions.saveuserEmailSharePreference(emailUser.text);
      setState(() {
        isLoading = true;
      });
      databaseService.getUserByUserEmail(emailUser.text).then((value) {
        querySnapshot = value;
        HelperFunctions.saveuserNameSharePreference(
            querySnapshot.documents[0].data['name']);
      });
      authService
          .signInWithEmailAndPassword(emailUser.text, passWordUser.text)
          .then((authResult) async {
        if (authResult != null) {
          String fcmToken = await firebaseMessaging.getToken();
          FirebaseAuth auth = FirebaseAuth.instance;
          FirebaseUser user = await auth.currentUser();

          databaseService.uploadToken(user.uid, user.email,fcmToken);

          firebaseMessaging.subscribeToTopic("promotion");
          firebaseMessaging.subscribeToTopic("news");

          HelperFunctions.saveuserLoggedInSharePreference(true);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(),
              ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
                Expanded(
                    child: Image.asset(
                  "images/logo app.png",
                  fit: BoxFit.cover,
                )),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)
                                ? null
                                : "Please provide a valid email";
                          },
                          controller: emailUser,
                          style: simpleTextFieldStyle(),
                          decoration: textfieldInputDecoration("Email")),
                      TextFormField(
                          obscureText: true,
                          validator: (value) {
                            return value.length > 6
                                ? null
                                : "Please provide password 6+ characters";
                          },
                          controller: passWordUser,
                          style: simpleTextFieldStyle(),
                          decoration: textfieldInputDecoration("Password")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Text("Forgot Password ?",
                        style: simpleTextFieldStyle()),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: () {
                    CircularProgressIndicator();
                    signIn();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text("Sign In", style: mediumTextFieldStyle()),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: LinearGradient(colors: [
                          const Color(0xff007EF4),
                          Color(0xff2A75BC)
                        ])),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text("Sign In with Google",
                        style:
                            TextStyle(color: Colors.black87, fontSize: 17.0)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    )),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have account?",
                      style: mediumTextFieldStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(" Register now",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                  decoration: TextDecoration.underline))),
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
