import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset("images/title.png"),
  );
}
 gradient(){
  return LinearGradient(colors: [
    Color(0xFFBA68C8),
    Colors.purple,
  ]);
}

InputDecoration textfieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)));
}

TextStyle simpleTextFieldStyle() {
  return TextStyle(color: Colors.white,fontSize: 16.0);
}

TextStyle mediumTextFieldStyle() {
  return TextStyle(color: Colors.white,fontSize: 17.0);
}

Widget container(IconData icon,bool isClicked){
  return Container(
      decoration: BoxDecoration(
        color: isClicked ? Colors.white : Color(0xFFBA68C8),
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(width: 2, color: Colors.white),
      ),
      padding: EdgeInsets.all(5.0),
      child: Center(child: Icon(icon,color: Colors.white)));
}
