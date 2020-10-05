import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/helper/helperFunctions.dart';
import 'package:flutter_app_chat_last_version/service/authService.dart';
import 'package:flutter_app_chat_last_version/service/database.dart';
import 'package:flutter_app_chat_last_version/widgets/widget.dart';

import 'chatRoomScreen.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  AuthService authService = new AuthService();
  DatabaseService databaseService = new DatabaseService();
  bool isLoading = false;

  TextEditingController userName = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController passWord = new TextEditingController();

  signMeUp() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
        authService.signUpWithEmailAndPassword(email.text, passWord.text);
        Map<String, String> userInfoMap = {
          "name": userName.text,
          "email": email.text,
        };
        HelperFunctions.saveuserEmailSharePreference(email.text);
        HelperFunctions.saveuserNameSharePreference(userName.text);
        databaseService.uploadUserInfo(userInfoMap);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoom(),
            ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
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
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                  validator: (value) {
                                    return value.isEmpty || value.length < 2
                                        ? "Please provide username"
                                        : null;
                                  },
                                  controller: userName,
                                  style: simpleTextFieldStyle(),
                                  decoration:
                                      textfieldInputDecoration("UserName")),
                              TextFormField(
                                  validator: (value) {
                                    return RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value)
                                        ? null
                                        : "Please provide a valid email";
                                  },
                                  controller: email,
                                  style: simpleTextFieldStyle(),
                                  decoration:
                                      textfieldInputDecoration("Email")),
                              TextFormField(
                                  obscureText: true,
                                  validator: (value) {
                                    return value.length > 6
                                        ? null
                                        : "Please provide password 6+ characters";
                                  },
                                  controller: passWord,
                                  style: simpleTextFieldStyle(),
                                  decoration:
                                      textfieldInputDecoration("Password")),
                            ],
                          )),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: Text("Forgot Password ?",
                              style: simpleTextFieldStyle()),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          signMeUp();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Text("Sign Up", style: mediumTextFieldStyle()),
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
                          child: Text("Sign Up with Google",
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 17.0)),
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
                            "Already have account?",
                            style: mediumTextFieldStyle(),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.toggle();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(" SignIn now",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                      decoration: TextDecoration.underline)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
