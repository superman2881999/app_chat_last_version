import 'package:flutter/material.dart';

class MessageSticker extends StatelessWidget{
  final String message;
  final bool sendByMe;
  MessageSticker({this.message, this.sendByMe});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding:
        EdgeInsets.only(left: sendByMe ? 250 : 25, right: sendByMe ? 25 : 250),
        margin: EdgeInsets.symmetric(vertical: 4),
        width: MediaQuery.of(context).size.width,
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Image.asset(message));
  }
}
