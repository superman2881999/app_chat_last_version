import 'package:flutter/material.dart';
import 'package:flutter_app_chat_last_version/views/signin.dart';
import 'package:flutter_app_chat_last_version/views/signup.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void Toggle() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(Toggle);
    } else {
      return SignUp(Toggle);
    }
  }
}
