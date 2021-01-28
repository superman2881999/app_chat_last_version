import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset("images/title.png"),
  );
}

gradient() {
  return LinearGradient(colors: [
    Colors.red,
    Colors.yellow,
  ]);
}

gradient2() {
  return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.red,
        Colors.yellow,
      ]);
}

InputDecoration textfieldInputDecoration(String hintText) {
  return InputDecoration(
      labelText: hintText,
      labelStyle: TextStyle(color: Colors.grey),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)));
}

TextStyle simpleTextFieldStyle() {
  return TextStyle(color: Colors.black, fontSize: 16.0);
}

TextStyle greyColorText() {
  return TextStyle(
      color: Colors.grey, fontSize: 13.0, decoration: TextDecoration.underline);
}

TextStyle minTextFieldStyle() {
  return TextStyle(color: Colors.black, fontSize: 13.0);
}

TextStyle mediumTextFieldStyle() {
  return TextStyle(color: Colors.white, fontSize: 17.0);
}

Widget container(IconData icon) {
  return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF44336),
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(width: 2, color: Colors.white),
      ),
      padding: EdgeInsets.all(5.0),
      child: Center(child: Icon(icon, color: Colors.white)));
}

Widget card(String action,dynamic amount,String target,AnimationController resizableController){
  return SizedBox(
    height: 150,
    width: 150,
    child:  getContainer( action, amount, target, resizableController),
  );
}

AnimatedBuilder getContainer(String action,dynamic amount,String target,AnimationController resizableController) {
  return AnimatedBuilder(
      animation: resizableController,
      builder: (context, child) {
        return Container(
          child: Card(
            elevation: 10.0,
            shape: new RoundedRectangleBorder(
                side: new BorderSide(color: Colors.redAccent, width: 2.0),
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(action),
                Text("$amount",style: TextStyle(fontSize: amount.runtimeType == String ? 20.0 : 30.0)),
                Text(target),
              ],
            ),
          ),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
                color: Colors.redAccent, width: resizableController.value * 7),
          ),
        );
      });
}


